terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/nat-instance-zonal-vpc/main.tfstate"
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

resource "aws_iam_instance_profile" "Instance_profile" {
  name = "Instance_profile"
  path = "/"
  role = aws_iam_role.Instance_role.name
  tags = {
    Name           = "Instance_profile"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "Instance_role" {
  name                  = "Instance_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "Instance_role"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "nat-instance-zonal-vpc" {
  cidr_block         = "10.105.0.0/16"
  enable_dns_support = true
  instance_tenancy   = "default"
  tags = {
    Name           = "nat-instance-zonal-vpc"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "zonal-private-a" {
  vpc_id                              = aws_vpc.nat-instance-zonal-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.105.0.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "zonal-private-a"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "zonal-public-a" {
  vpc_id                              = aws_vpc.nat-instance-zonal-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.105.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "zonal-public-a"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "zonal-igw" {
  vpc_id = aws_vpc.nat-instance-zonal-vpc.id
  tags = {
    Name           = "zonal-igw"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_zonal-rt-private_to_Instance_ipv4" {
  network_interface_id   = aws_instance.Instance.primary_network_interface_id
  route_table_id         = aws_route_table.zonal-rt-private.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_zonal-rt-public_to_zonal-igw_ipv4" {
  gateway_id             = aws_internet_gateway.zonal-igw.id
  route_table_id         = aws_route_table.zonal-rt-public.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "zonal-rt-private" {
  vpc_id = aws_vpc.nat-instance-zonal-vpc.id
  tags = {
    Name           = "zonal-rt-private"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "zonal-rt-public" {
  vpc_id = aws_vpc.nat-instance-zonal-vpc.id
  tags = {
    Name           = "zonal-rt-public"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_zonal_private_a_zonal_rt_private" {
  route_table_id = aws_route_table.zonal-rt-private.id
  subnet_id      = aws_subnet.zonal-private-a.id
}

resource "aws_route_table_association" "aws_route_table_association_zonal_public_a_zonal_rt_public" {
  route_table_id = aws_route_table.zonal-rt-public.id
  subnet_id      = aws_subnet.zonal-public-a.id
}

resource "aws_security_group" "instance_Instance_group" {
  name                   = "instance_Instance_group"
  vpc_id                 = aws_vpc.nat-instance-zonal-vpc.id
  description            = "Accepts every protocol from the VPC CIDR, which is the traffic this NAT instance forwards. Egress open."
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_Instance_group"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_instance_Instance_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_Instance_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_Instance_group_ingress_all_protocols" {
  security_group_id = aws_security_group.instance_Instance_group.id
  cidr_blocks       = ["10.105.0.0/16"]
  description       = "Traffic from the VPC that the private route table sends here"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "ingress"
}

resource "aws_eip" "EIP" {
  instance             = aws_instance.Instance.id
  network_border_group = "us-west-2"
  public_ipv4_pool     = "amazon"
  tags = {
    Name           = "EIP"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_internet_gateway.zonal-igw]
}




### CATEGORY: COMPUTE ###

resource "aws_instance" "Instance" {
  subnet_id                   = aws_subnet.zonal-public-a.id
  ami                         = "ami-0cc098d14c47f965b"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.Instance_profile.name
  instance_type               = "t3.nano"
  private_ip                  = "10.105.1.243"
  source_dest_check           = false
  user_data_base64 = base64encode(<<-EOFUData
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
)
  vpc_security_group_ids = [aws_security_group.instance_Instance_group.id]
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
    Name = "Instance"
  }
  }
  tags = {
    Name           = "Instance"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}


