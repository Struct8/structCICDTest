terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/natpriv_import/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "kuma_profile" {
  name = "kuma_profile"
  path = "/"
  role = aws_iam_role.kuma_role.name
  tags = {
    Name           = "kuma_profile"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "nat_profile" {
  name = "nat_profile"
  path = "/"
  role = aws_iam_role.nat_role.name
  tags = {
    Name           = "nat_profile"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "kuma_role" {
  name                  = "kuma_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "kuma_role"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "nat_role" {
  name                  = "nat_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "nat_role"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "ec2-nat-private" {
  cidr_block         = "10.4.0.0/16"
  enable_dns_support = true
  instance_tenancy   = "default"
  tags = {
    Name           = "ec2-nat-private"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private" {
  vpc_id                              = aws_vpc.ec2-nat-private.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.4.2.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "private"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public" {
  vpc_id                              = aws_vpc.ec2-nat-private.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.4.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "public"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ec2-nat-private.id
  tags = {
    Name           = "igw"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_private-rt_to_nat_ipv4" {
  network_interface_id   = aws_instance.nat.primary_network_interface_id
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_public-rt_to_igw_ipv4" {
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.ec2-nat-private.id
  tags = {
    Name           = "private-rt"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.ec2-nat-private.id
  tags = {
    Name           = "public-rt"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_private_private_rt" {
  route_table_id = aws_route_table.private-rt.id
  subnet_id      = aws_subnet.private.id
}

resource "aws_route_table_association" "aws_route_table_association_public_public_rt" {
  route_table_id = aws_route_table.public-rt.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_security_group" "instance_kuma_group" {
  name                   = "instance_kuma_group"
  vpc_id                 = aws_vpc.ec2-nat-private.id
  description            = "Uptime Kuma public access"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_kuma_group"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_nat_group" {
  name                   = "instance_nat_group"
  vpc_id                 = aws_vpc.ec2-nat-private.id
  description            = "NAT instance"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_nat_group"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_instance_kuma_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_kuma_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All outbound"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_kuma_group_ingress_tcp_3001" {
  security_group_id = aws_security_group.instance_kuma_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Kuma web UI"
  from_port         = 3001
  protocol          = "tcp"
  to_port           = 3001
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_nat_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_nat_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All outbound"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_nat_group_ingress_all_protocols" {
  security_group_id = aws_security_group.instance_nat_group.id
  cidr_blocks       = ["10.4.0.0/16"]
  description       = "All from VPC"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_nat_group_ingress_tcp_3001" {
  security_group_id = aws_security_group.instance_nat_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Kuma UI (forwarded to private)"
  from_port         = 3001
  protocol          = "tcp"
  to_port           = 3001
  type              = "ingress"
}




### CATEGORY: COMPUTE ###

resource "aws_instance" "kuma" {
  subnet_id                   = aws_subnet.private.id
  ami                         = "ami-0cc098d14c47f965b"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.kuma_profile.name
  instance_type               = "t3.nano"
  private_ip                  = "10.4.2.10"
  user_data = <<-EOFUData
#!/bin/bash

#!/bin/bash
# Uptime Kuma on Amazon Linux 2023 via Docker.
# Boots Docker, runs louislam/uptime-kuma on port 3001, and restarts it on reboot.
#
# This instance is a t3.nano (512 MB) in a PRIVATE subnet, reaching the internet only through the
# NAT instance. Two things that bit this before are handled here:
#   1. OOM: `dnf update` + `dnf install docker` peaks over what 512 MB has free, and the kernel
#      OOM-kills dnf mid-install (seen as "Killed" in the log), so Docker never installs and the
#      container never starts -- nothing then listens on 3001 and the NAT's port-forward lands on a
#      dead target (connection refused). A temporary swapfile gives dnf the headroom. We also skip
#      the heavy `dnf update` and just install docker.
#   2. Docker not ready yet: wait for the daemon before `docker run`.
set -uo pipefail
LOGFILE="/var/log/user-data.log"
exec >"$LOGFILE" 2>&1
set -x

# A temporary 1G swapfile so dnf is not OOM-killed on a 512 MB instance. Removed afterwards; on a
# bigger instance it simply goes unused.
if ! swapon --show | grep -q /swapfile; then
  echo "Adding a temporary 1G swapfile..."
  fallocate -l 1G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=1024
  chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
fi

echo "Installing Docker..."
# No `dnf update` -- it is heavy and unnecessary just to get Docker, and it was part of what pushed
# the nano into OOM. Retry to ride out a NAT path that is briefly not ready at first boot.
for attempt in 1 2 3 4 5; do
  if dnf install -y docker; then break; fi
  echo "dnf install docker failed (attempt $attempt), retrying in 5s..."
  sleep 5
done
systemctl enable docker
systemctl start docker

# The swap was only needed for the install; drop it so nothing lingers.
swapoff /swapfile 2>/dev/null && rm -f /swapfile

echo "Waiting for the Docker daemon..."
for i in $(seq 1 30); do
  if docker info >/dev/null 2>&1; then break; fi
  sleep 2
done

echo "Running Uptime Kuma..."
docker rm -f uptime-kuma 2>/dev/null || true
# Image tag: `2` is the project's recommended tag -- the latest of the v2 series, which gets
# the fixes and security updates. NOT `latest` (deprecated, still points at the unmaintained v1,
# which makes the UI show an "outdated version" warning) and NOT `1` (the v1 series, also no longer
# maintained). `2` tracks v2 without ever jumping to a future major that could break.
docker run -d \
  --name uptime-kuma \
  --restart unless-stopped \
  -p 3001:3001 \
  -v uptime-kuma:/app/data \
  louislam/uptime-kuma:2

# Verify the container is actually up, rather than trust: a dead container is exactly what makes
# the NAT port-forward answer "connection refused".
sleep 3
if docker ps --filter name=uptime-kuma --filter status=running | grep -q uptime-kuma; then
  echo "Done. Uptime Kuma is running on port 3001."
else
  echo "ERROR: the uptime-kuma container is NOT running. Recent docker state:" >&2
  docker ps -a >&2
  exit 1
fi

EOFUData

  vpc_security_group_ids = [aws_security_group.instance_kuma_group.id]
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
    Name = "kuma"
  }
  }
  tags = {
    Name           = "kuma"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_instance" "nat" {
  subnet_id                   = aws_subnet.public.id
  ami                         = "ami-0cc098d14c47f965b"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.nat_profile.name
  instance_type               = "t3.nano"
  private_ip                  = "10.4.1.251"
  source_dest_check           = false
  user_data = <<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
FORWARD_PORT="3001"
FORWARD_TARGET="10.4.2.10"
NAME="nat"
REGION="us-west-2"
ACCOUNT="952133486861"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

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

  vpc_security_group_ids = [aws_security_group.instance_nat_group.id]
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
    Name = "nat"
  }
  }
  tags = {
    Name           = "nat"
    State          = "natpriv_import"
    Struct8Creator = "rmay struct"
  }
}


