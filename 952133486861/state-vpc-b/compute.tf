resource "aws_instance" "nat-b" {
  subnet_id                   = aws_subnet.vpc-b-public.id
  ami                         = "ami-0cc098d14c47f965b"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.nat-b_profile.name
  instance_type               = "t3.nano"
  private_ip                  = "10.1.1.17"
  source_dest_check           = false
  user_data = <<-EOFUData
#!/bin/bash

#!/bin/bash
# Generic NAT instance bootstrap for Amazon Linux 2023 - reusable across templates.
# Always: routes outbound traffic from the VPC to the internet (source NAT / MASQUERADE),
#         with a default-DROP FORWARD chain so the box is not an open router.
# Optional: if FORWARD_PORT and FORWARD_TARGET are set (node environment variables),
#           it also forwards that inbound port to a private host (destination NAT).
# Notes:
#   - Small instances (t3.nano, 512 MB) can OOM-kill dnf, so we add a little swap first
#     and avoid heavy packages: AL2023 already ships the `iptables` command.
#   - Reads node variables from /etc/profile.d/struct8_vars.sh (the generator writes them
#     there with `export`); /etc/environment is NOT valid shell to source.
#   - Requires source_dest_check disabled on the instance (the template does that).
set -uo pipefail
LOGFILE="/var/log/user-data.log"
exec >"$LOGFILE" 2>&1

# Load node variables (FORWARD_PORT / FORWARD_TARGET, if set on the node).
# The generator writes them as  export KEY   = "value"  (spaces + quotes), which is NOT
# valid shell to source, so parse the value out instead of sourcing.
VARS=/etc/profile.d/struct8_vars.sh
getvar() { [ -f "$VARS" ] && awk -F= -v k="$1" '$0 ~ k {gsub(/[ "]/,"",$2); print $2; exit}' "$VARS"; }
FORWARD_PORT=$(getvar FORWARD_PORT)
FORWARD_TARGET=$(getvar FORWARD_TARGET)

# A little swap so dnf does not get OOM-killed on a 512 MB instance.
if [ ! -f /swapfile ]; then
  dd if=/dev/zero of=/swapfile bs=1M count=512 2>/dev/null
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
fi

echo "Ensuring iptables is present..."
command -v iptables >/dev/null 2>&1 || dnf install -y iptables

echo "Enabling IPv4 forwarding..."
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-nat.conf
sysctl -p /etc/sysctl.d/99-nat.conf

PRIMARY_IF=$(ip route | awk '/default/ {print $5; exit}')

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
MAC=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/mac)
VPC_CIDR=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  "http://169.254.169.254/latest/meta-data/network/interfaces/macs/$${MAC}/vpc-ipv4-cidr-block")
echo "IF=$PRIMARY_IF  VPC=$VPC_CIDR  FORWARD_PORT=$${FORWARD_PORT:-<none>}  FORWARD_TARGET=$${FORWARD_TARGET:-<none>}"

echo "Base NAT rules (outbound only, scoped to the VPC)..."
iptables -t nat -F
iptables -F FORWARD
iptables -P FORWARD DROP
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s "$VPC_CIDR" -o "$PRIMARY_IF" -j ACCEPT
iptables -t nat -A POSTROUTING -s "$VPC_CIDR" -o "$PRIMARY_IF" -j MASQUERADE

# Optional destination NAT (port forward) - only if both vars are set.
if [ -n "$${FORWARD_PORT:-}" ] && [ -n "$${FORWARD_TARGET:-}" ]; then
  echo "Port forward: :$${FORWARD_PORT} -> $${FORWARD_TARGET}:$${FORWARD_PORT}"
  iptables -t nat -A PREROUTING -i "$PRIMARY_IF" -p tcp --dport "$FORWARD_PORT" \
    -j DNAT --to-destination "$${FORWARD_TARGET}:$${FORWARD_PORT}"
  iptables -A FORWARD -p tcp -d "$FORWARD_TARGET" --dport "$FORWARD_PORT" -j ACCEPT
  # SNAT the forwarded traffic so the target replies to THIS instance, not to
  # the original client. Without it the target answers the client's real IP
  # directly, the reply does not match the client's TCP session with the NAT,
  # and the connection hangs -- the classic DNAT-without-SNAT hairpin. With it,
  # the target sees the NAT as the source and its reply returns through here.
  iptables -t nat -A POSTROUTING -p tcp -d "$FORWARD_TARGET" --dport "$FORWARD_PORT" \
    -o "$PRIMARY_IF" -j MASQUERADE
fi

# Persist rules across reboot without the heavy iptables-services package.
iptables-save > /etc/sysconfig/iptables
cat > /etc/systemd/system/nat-restore.service <<'EOF'
[Unit]
Description=Restore iptables NAT rules
After=network-online.target
Wants=network-online.target
[Service]
Type=oneshot
ExecStart=/bin/sh -c 'iptables-restore < /etc/sysconfig/iptables'
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
systemctl enable nat-restore.service
echo "Done."

EOFUData

  vpc_security_group_ids = [aws_security_group.instance_nat-b_group.id]
  cpu_options {
    core_count       = 1
    threads_per_core = 2
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  enclave_options {
    enabled = false
  }
  lifecycle {
    ignore_changes = [user_data_replace_on_change]
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }
  private_dns_name_options {
    enable_resource_name_dns_a_record    = false
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
  root_block_device {
    kms_key_id  = "arn:aws:kms:us-west-2:952133486861:key/f019f965-2340-4c77-b976-182a1c3460ab"
    encrypted   = true
    iops        = 3000
    throughput  = 125
    volume_size = 8
    volume_type = "gp3"
    tags = {
      Name = "nat-b"
    }
  }
  tags = {
    Name           = "nat-b"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_launch_template" "traffic-gen-asg-lt" {
  image_id               = "ami-0cc2cd1a7e55e5a3f"
  name                   = "traffic-gen-asg-lt"
  description            = "Launch template of traffic-gen-asg: t4g.nano Spot on Amazon Linux 2023, running PrivateTrafficGenerator.sh. It pings traffic-gen-private and opens SSH, HTTP and DNS conversations with it, plus one on MySQL (3306) "
  instance_type          = "t4g.nano"
  update_default_version = true
  user_data = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
PING_TARGET="10.5.1.10"
PROBE="10.5.1.10:22/tcp 10.5.1.10:80/tcp 10.5.1.10:53/udp 10.5.1.10:3306/tcp"
NAME="traffic-gen-asg"
REGION="us-west-2"
ACCOUNT="952133486861"
AWS_DYNAMODB_TABLE_NAME_0="traffic-table-b"
AWS_INSTANCE_NAME_0="nat-b"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

#!/bin/bash
# Boot script of the traffic generators in the private subnets of the VPC Flow
# Logs + Managed Prometheus lab: traffic-gen-private, and every instance
# traffic-gen-asg launches.
#
# Everything it does is switched on by a variable in /etc/struct8_env, which the
# compile writes from the node's connections and environment variables. A
# variable that is missing switches its part off, and the rest keeps running.
#
# Every 15 seconds, as a client:
#
#   AWS_S3_BUCKET_NAME_0        put, get and delete of a 256 KB object in the
#                               wired bucket, through the S3 gateway endpoint
#   AWS_DYNAMODB_TABLE_NAME_0   put and get of one item in the wired table,
#                               through the DynamoDB gateway endpoint
#   PING_TARGET                 ten 1200-byte pings to each address (ICMP)
#   PROBE                       one conversation per host:port/protocol, for
#                               example "10.5.1.10:80/tcp 10.5.1.10:53/udp":
#                               TCP sends a request and reads the whole answer,
#                               UDP sends 512 bytes and waits for the echo
#   (always)                    one HTTPS request to checkip.amazonaws.com and
#                               one to www.google.com, through the NAT instance
#
# As a server:
#
#   LISTEN                      answers on each port/protocol, for example
#                               "80/tcp 53/udp": a TCP connection gets an HTTP
#                               response with 32 KB of body, a UDP datagram
#                               gets itself back. SSH already answers on 22.
#
# Each port is a separate line in the Traffic layer's protocol breakdown, which
# names the well-known ones (22 SSH, 53 DNS, 80 HTTP). What reaches the server
# is decided by its security group, so the lab shows a rule per protocol.
#
# The object is deleted right after it is read, so the bucket stays empty and a
# destroy does not stop on it.

cat >/usr/local/bin/struct8-serve.py <<'EOF'
#!/usr/bin/env python3
"""Answers on every port in LISTEN ("80/tcp 53/udp")."""
import os
import socket
import threading

BODY = b"x" * 32768
HEADER = b"HTTP/1.0 200 OK\r\nContent-Length: %d\r\n\r\n" % len(BODY)


def tcp(port):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", port))
    server.listen(16)
    while True:
        conn, _ = server.accept()
        try:
            conn.settimeout(3)
            conn.recv(4096)
            conn.sendall(HEADER + BODY)
        except OSError:
            pass
        finally:
            conn.close()


def udp(port):
    server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server.bind(("0.0.0.0", port))
    while True:
        data, peer = server.recvfrom(2048)
        server.sendto(data, peer)


for item in os.environ.get("LISTEN", "").split():
    port, _, protocol = item.partition("/")
    serve = udp if protocol == "udp" else tcp
    threading.Thread(target=serve, args=(int(port),)).start()
EOF

cat >/usr/local/bin/struct8-probe.py <<'EOF'
#!/usr/bin/env python3
"""Opens one conversation per item in PROBE ("10.5.1.10:80/tcp 10.5.1.10:53/udp")."""
import os
import socket

for item in os.environ.get("PROBE", "").split():
    address, _, protocol = item.partition("/")
    host, _, port = address.rpartition(":")
    try:
        if protocol == "udp":
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(2)
            sock.sendto(b"q" * 512, (host, int(port)))
            sock.recvfrom(2048)
        else:
            sock = socket.create_connection((host, int(port)), timeout=3)
            sock.settimeout(3)
            sock.sendall(b"GET / HTTP/1.0\r\n\r\n")
            while sock.recv(65536):
                pass
        sock.close()
    except OSError:
        pass
EOF
chmod +x /usr/local/bin/struct8-serve.py /usr/local/bin/struct8-probe.py

cat >/usr/local/bin/struct8-private-traffic.sh <<'EOF'
#!/bin/bash
[ -f /etc/struct8_env ] && . /etc/struct8_env
BUCKET="$${AWS_S3_BUCKET_NAME_0:-}"
TABLE="$${AWS_DYNAMODB_TABLE_NAME_0:-}"
TARGETS="$${PING_TARGET:-}"
PROBES="$${PROBE:-}"
REGION="$${REGION:-us-east-1}"

PAYLOAD=/var/tmp/struct8-payload.bin
head -c 262144 /dev/urandom >"$PAYLOAD"

while true; do
  KEY="traffic/$(hostname)-$(date +%s)"
  if [ -n "$BUCKET" ]; then
    aws s3api put-object --region "$REGION" --bucket "$BUCKET" --key "$KEY" --body "$PAYLOAD" >/dev/null 2>&1
    aws s3api get-object --region "$REGION" --bucket "$BUCKET" --key "$KEY" /var/tmp/struct8-read.bin >/dev/null 2>&1
    aws s3api delete-object --region "$REGION" --bucket "$BUCKET" --key "$KEY" >/dev/null 2>&1
  fi
  if [ -n "$TABLE" ]; then
    aws dynamodb put-item --region "$REGION" --table-name "$TABLE" --item "{\"ID\":{\"S\":\"$KEY\"}}" >/dev/null 2>&1
    aws dynamodb get-item --region "$REGION" --table-name "$TABLE" --key "{\"ID\":{\"S\":\"$KEY\"}}" >/dev/null 2>&1
  fi
  for TARGET in $TARGETS; do
    ping -c 10 -i 0.2 -s 1200 -W 2 "$TARGET" >/dev/null 2>&1
  done
  if [ -n "$PROBES" ]; then
    PROBE="$PROBES" python3 /usr/local/bin/struct8-probe.py
  fi
  curl -s -o /dev/null --max-time 5 https://checkip.amazonaws.com/
  curl -s -o /dev/null --max-time 5 https://www.google.com/
  sleep 15
done
EOF
chmod +x /usr/local/bin/struct8-private-traffic.sh

cat >/etc/systemd/system/struct8-private-traffic.service <<'UNIT'
[Unit]
Description=Traffic generator of a private subnet, for the VPC flow log lab
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/struct8-private-traffic.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

cat >/etc/systemd/system/struct8-serve.service <<'UNIT'
[Unit]
Description=Ports the VPC flow log lab probes, from LISTEN
After=network-online.target
Wants=network-online.target

[Service]
EnvironmentFile=-/etc/struct8_env
ExecStart=/usr/bin/python3 /usr/local/bin/struct8-serve.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now struct8-private-traffic.service
if grep -q '^LISTEN=' /etc/struct8_env 2>/dev/null; then
  systemctl enable --now struct8-serve.service
fi

EOFUData
)
  vpc_security_group_ids = [aws_security_group.autoscaling_group_traffic-gen-asg_group.id]
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 8
      volume_type           = "gp3"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.traffic-gen-asg_profile.name
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name           = "traffic-gen-asg"
      State          = "state-vpc-b"
      Struct8Creator = "rmay struct"
      Struct8Debug   = "dSoyaOy7hbpHYVsbxeFUF"
    }
  }
  tags = {
    Name           = "traffic-gen-asg-lt"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_autoscaling_group" "traffic-gen-asg" {
  name                  = "traffic-gen-asg"
  desired_capacity      = 2
  health_check_type     = "EC2"
  max_instance_lifetime = 0
  max_size              = 2
  min_size              = 2
  termination_policies  = ["Default"]
  vpc_zone_identifier   = [aws_subnet.vpc-b-private.id]
  availability_zone_distribution {
    capacity_distribution_strategy = "balanced-best-effort"
  }
  capacity_reservation_specification {
    capacity_reservation_preference = "default"
  }
  launch_template {
    version = "1"
    id      = aws_launch_template.traffic-gen-asg-lt.id
  }
  tag {
    key                 = "Struct8Debug"
    propagate_at_launch = true
    value               = "dSoyaOy7hbpHYVsbxeFUF"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "traffic-gen-asg"
  }
  tag {
    key                 = "State"
    propagate_at_launch = true
    value               = "state-vpc-b"
  }
  tag {
    key                 = "Struct8Creator"
    propagate_at_launch = true
    value               = "rmay struct"
  }
}
