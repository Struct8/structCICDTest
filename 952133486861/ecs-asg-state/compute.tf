resource "aws_instance" "ecs-asg-k6" {
  subnet_id                   = aws_subnet.ecs-asg-public-a.id
  ami                         = "ami-0cc2cd1a7e55e5a3f"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ecs-asg-k6_profile.name
  instance_type               = "t4g.nano"
  private_ip                  = "10.6.0.87"
  user_data = <<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
K6_PANEL="on"
K6_PANEL_REF="main"
TARGET_URL="http://ecs-asg-alb-1745934589.us-west-2.elb.amazonaws.com/loadtest?ms=80"
NAME="ecs-asg-k6"
REGION="us-west-2"
ACCOUNT="952133486861"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

#!/bin/bash
# k6 load generator on Amazon Linux 2023.
#
# Architecture-neutral: it runs unchanged on x86_64 and on arm64 (Graviton,
# e.g. t4g), because it assumes no CPU. The Docker platform is detected at boot
# and grafana/k6 (a multi-arch image) is pulled for exactly that platform. So
# swapping the instance family -- and its matching AMI -- does not require a
# script change.
#
# Boots Docker, pulls the grafana/k6 image, and drops a ready-to-run k6 test
# script on disk. It does NOT run a test on boot: the test is fired on demand by
# an agent (or a person) through Struct8 Debug Access / SSM, so that load starts
# only when someone asks for it.
#
# This template ships its own VPC and a public subnet, so the generator is not
# tied to any particular target. The endpoint under test is passed per run as
# TARGET_URL:
#   TARGET_URL=https://your-service.example.com/ /opt/k6/run.sh
#   RPS=200 VUS=100 DURATION=5m TARGET_URL=https://... /opt/k6/run.sh
#
# TARGET_URL, VUS, DURATION and RPS are read by the script from the environment,
# so the same script covers every scenario without an edit or a redeploy.
LOGFILE="/var/log/user-data.log"
exec >$LOGFILE 2>&1
set -x

echo "Updating the system..."
dnf update -y

echo "Installing Docker..."
dnf install -y docker
systemctl enable docker
systemctl start docker

# Architecture-aware: this script must boot on both x86_64 and arm64 (Graviton),
# so nothing here assumes a CPU. We detect the arch, map it to the Docker
# platform string, and pull grafana/k6 for exactly that platform -- grafana/k6
# is a multi-arch image, so the right layers are fetched instead of relying on
# the daemon guessing. If a platform ever has no manifest, we fail loudly here
# rather than at `docker run` time.
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64)  K6_PLATFORM="linux/amd64" ;;
  aarch64|arm64) K6_PLATFORM="linux/arm64" ;;
  *)             echo "Unsupported CPU architecture: $ARCH" >&2; exit 1 ;;
esac
echo "Detected architecture: $ARCH -> Docker platform $K6_PLATFORM"
echo "$K6_PLATFORM" > /opt/k6/platform 2>/dev/null || { mkdir -p /opt/k6; echo "$K6_PLATFORM" > /opt/k6/platform; }

echo "Pulling the k6 image for $K6_PLATFORM..."
if ! docker pull --platform "$K6_PLATFORM" grafana/k6:latest; then
  echo "Failed to pull grafana/k6:latest for $K6_PLATFORM. No image for this architecture?" >&2
  exit 1
fi

echo "Writing the k6 test script..."
mkdir -p /opt/k6/scripts
cat > /opt/k6/scripts/load-test.js <<'K6EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Every knob comes from the environment, so one script serves every run.
// The agent sets these with -e on `docker run` -- no edit, no redeploy.
const TARGET_URL = __ENV.TARGET_URL || 'http://localhost/';
const VUS = parseInt(__ENV.VUS || '10', 10);
const DURATION = __ENV.DURATION || '30s';
// HTTP method. Default GET. Set METHOD=POST for targets whose work endpoint
// only answers POST -- the Struct8 Hub load-test endpoint is one of them
// (POST /loadtest?ms=N; a GET there returns 405 and every check fails).
const METHOD = (__ENV.METHOD || 'GET').toUpperCase();
const BODY = __ENV.BODY || '';
// Optional fixed request rate. When RPS is set the test holds that arrival
// rate regardless of latency, which is the honest way to measure a system
// under a known load. When it is unset the VUs loop as fast as they can.
const RPS = __ENV.RPS ? parseInt(__ENV.RPS, 10) : 0;
// Optional load curve. STAGES is a JSON list of {"target": VUs, "duration": "30s"}
// and START_VUS the VUs at t=0: k6 ramps linearly from one target to the next.
// When STAGES is set it wins over VUS/DURATION/RPS. The control panel's curve
// editor writes these two; an agent can set them too:
//   STAGES='[{"target":50,"duration":"1m"},{"target":0,"duration":"30s"}]' /opt/k6/run.sh
const STAGES = __ENV.STAGES ? JSON.parse(__ENV.STAGES) : null;
const START_VUS = parseInt(__ENV.START_VUS || '0', 10);

const errorRate = new Rate('failed_requests');

export const options = STAGES
  ? {
      scenarios: {
        curve: {
          executor: 'ramping-vus',
          startVUs: START_VUS,
          stages: STAGES,
          gracefulRampDown: '10s',
        },
      },
      thresholds: {
        http_req_duration: ['p(95)<1000'],
        failed_requests: ['rate<0.01'],
      },
    }
  : RPS > 0
  ? {
      scenarios: {
        constant_rate: {
          executor: 'constant-arrival-rate',
          rate: RPS,
          timeUnit: '1s',
          duration: DURATION,
          preAllocatedVUs: VUS,
          maxVUs: VUS * 4,
        },
      },
      thresholds: {
        http_req_duration: ['p(95)<1000'],
        failed_requests: ['rate<0.01'],
      },
    }
  : {
      vus: VUS,
      duration: DURATION,
      thresholds: {
        http_req_duration: ['p(95)<1000'],
        failed_requests: ['rate<0.01'],
      },
    };

export default function () {
  const res = METHOD === 'POST'
    ? http.post(TARGET_URL, BODY)
    : http.request(METHOD, TARGET_URL);
  const ok = check(res, {
    'status is 2xx/3xx': (r) => r.status >= 200 && r.status < 400,
  });
  errorRate.add(!ok);
  sleep(1);
}
K6EOF

echo "Writing the run wrapper..."
cat > /opt/k6/run.sh <<'RUNEOF'
#!/bin/bash
# Convenience wrapper for a k6 run.
#
# Usage (from Debug Access, shell level):
#   TARGET_URL=https://your-service/ /opt/k6/run.sh
#   VUS=100 DURATION=5m TARGET_URL=https://your-service/ /opt/k6/run.sh
#   RPS=200 VUS=100 DURATION=5m TARGET_URL=https://your-service/ /opt/k6/run.sh
#
# TARGET_URL is required: this generator ships its own VPC and is not wired to
# any target, so the endpoint under test is given per run.
set -euo pipefail

[ -f /etc/struct8_env ] && source /etc/struct8_env

# Run on the same platform the image was pulled for (x86_64 or arm64). The
# platform was detected at boot and saved to /opt/k6/platform; fall back to the
# live arch if that file is missing.
if [ -f /opt/k6/platform ]; then
  K6_PLATFORM="$(cat /opt/k6/platform)"
else
  case "$(uname -m)" in
    x86_64|amd64)  K6_PLATFORM="linux/amd64" ;;
    aarch64|arm64) K6_PLATFORM="linux/arm64" ;;
    *)             K6_PLATFORM="" ;;
  esac
fi

if [ -z "$${TARGET_URL:-}" ]; then
  echo "TARGET_URL is required. Example: TARGET_URL=https://your-service/ /opt/k6/run.sh" >&2
  exit 1
fi

# The k6 web dashboard is served WHILE the test runs, on port 5665. It must
# bind 0.0.0.0 (not the default 127.0.0.1), because it runs inside the container
# and is reached from outside the instance; the port is published from the
# container, and a final HTML report is written so it survives the run.
DASHBOARD_PORT="$${DASHBOARD_PORT:-5665}"
echo "k6 -> $${TARGET_URL}  (VUS=$${VUS:-10} DURATION=$${DURATION:-30s} RPS=$${RPS:-unset}) on $${K6_PLATFORM:-native}"
echo "Live dashboard on port $${DASHBOARD_PORT} while the test runs."
# The grafana/k6 container runs as a non-root uid, so the report directory
# has to be world-writable or the HTML export fails with permission denied.
mkdir -p /opt/k6/report && chmod 777 /opt/k6/report
exec docker run --rm -i \
  $${K6_PLATFORM:+--platform "$${K6_PLATFORM}"} \
  -p "$${DASHBOARD_PORT}:$${DASHBOARD_PORT}" \
  -e TARGET_URL="$${TARGET_URL}" \
  -e VUS="$${VUS:-10}" \
  -e DURATION="$${DURATION:-30s}" \
  $${RPS:+-e RPS="$${RPS}"} \
  -e METHOD="$${METHOD:-GET}" \
  $${BODY:+-e BODY="$${BODY}"} \
  $${STAGES:+-e STAGES="$${STAGES}"} \
  $${START_VUS:+-e START_VUS="$${START_VUS}"} \
  -e K6_WEB_DASHBOARD=true \
  -e K6_WEB_DASHBOARD_HOST=0.0.0.0 \
  -e K6_WEB_DASHBOARD_PORT="$${DASHBOARD_PORT}" \
  -e K6_WEB_DASHBOARD_EXPORT=/report/index.html \
  -v /opt/k6/report:/report \
  grafana/k6 run - < /opt/k6/scripts/load-test.js
RUNEOF
chmod +x /opt/k6/run.sh

# ---------------------------------------------------------------------------
# Optional web control panel (K6_PANEL=on).
# ---------------------------------------------------------------------------
# A browser form on port 80 to set the target, VUs, duration, rate and method,
# and to start and stop runs; it embeds the live dashboard on 5665 while a run
# is going. It is OFF unless the node sets K6_PANEL=on, so an instance that never
# asked for a browser-facing UI boots exactly as before.
#
# Its two files are too large to inline here (user_data is capped at 16 KB), so
# they are fetched from this template's folder in the public repo. K6_PANEL_REF
# pins a branch, tag or commit (default main). The panel reads K6_PANEL_TOKEN,
# K6_PANEL_MAX_VUS and K6_PANEL_MAX_DURATION from the node environment; see the
# template README before opening port 80.
#
# TARGET_URL (optional): if the node sets it, the panel pre-fills the Target URL
# field with it and offers it as the first suggestion -- handy when the generator
# is not wired to its target and the URL comes from a Terraform interpolation,
# e.g. TARGET_URL="http://$${aws_lb.my-alb.dns_name}/loadtest?ms=80".
#
# Only the two switches are read here, in a subshell with tracing off, so the
# rest of the node environment (a token, say) never lands in this log.
panel_var() { ( set +x; [ -f /etc/struct8_env ] && . /etc/struct8_env; eval "printf '%s' \"\$${$1:-}\"" ); }
K6_PANEL="$(panel_var K6_PANEL)"
K6_PANEL_REF="$(panel_var K6_PANEL_REF)"
case "$(echo "$${K6_PANEL:-off}" | tr '[:upper:]' '[:lower:]')" in
  on|true|1|yes)
    PANEL_SRC="https://raw.githubusercontent.com/Struct8/struct8-templates/$${K6_PANEL_REF:-main}/templates/vpc-k6-load-generator/v2/control-panel"
    echo "Installing the k6 control panel from $${PANEL_SRC}..."
    # `dnf install nodejs` peaks well over what a 512 MB nano has free with Docker already running,
    # and the kernel OOM-kills dnf mid-install -- intermittently, since it depends on what else is
    # resident at that instant, which is why the panel came up on some nano boots and not others.
    # A temporary swapfile gives dnf the headroom to finish. It is removed afterwards so nothing
    # lingers; on an instance with plenty of RAM the swap simply goes unused.
    if ! swapon --show | grep -q /swapfile; then
      echo "Adding a temporary 1G swapfile so dnf is not OOM-killed on a small instance..."
      fallocate -l 1G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=1024
      chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
    fi
    dnf install -y nodejs
    swapoff /swapfile 2>/dev/null && rm -f /swapfile
    mkdir -p /opt/k6/panel /opt/k6/report && chmod 777 /opt/k6/report
    PANEL_OK=1
    for f in server.mjs index.html; do
      curl -fsSL --retry 5 --retry-delay 3 -o "/opt/k6/panel/$f" "$PANEL_SRC/$f" || PANEL_OK=0
    done
    if [ "$PANEL_OK" = 1 ]; then
      cat > /etc/systemd/system/struct8-k6-panel.service <<'PANELEOF'
[Unit]
Description=Struct8 k6 control panel (web UI on port 80)
After=docker.service network-online.target
Wants=docker.service network-online.target
[Service]
EnvironmentFile=-/etc/struct8_env
ExecStart=/usr/bin/node /opt/k6/panel/server.mjs
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
PANELEOF
      systemctl daemon-reload
      systemctl enable --now struct8-k6-panel.service
      echo "Control panel enabled on port 80 (journalctl -u struct8-k6-panel for its log)."
    else
      echo "Could not download the control panel from $${PANEL_SRC}; continuing without it." >&2
    fi
    ;;
  *)
    echo "Control panel off (set K6_PANEL=on on the node to enable it)."
    ;;
esac

echo "Done. k6 image is ready; test script is at /opt/k6/scripts/load-test.js."
echo "Fire a run through Debug Access: TARGET_URL=... /opt/k6/run.sh -- nothing runs on its own."

EOFUData

  vpc_security_group_ids = [aws_security_group.instance_ecs-asg-k6_group.id]
  cpu_options {
    core_count       = 2
    threads_per_core = 1
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
      Name = "ecs-asg-k6"
    }
  }
  tags = {
    Name           = "ecs-asg-k6"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_instance" "ecs-asg-nat-instance" {
  subnet_id                            = aws_subnet.ecs-asg-public-b.id
  ami                                  = "ami-0cc098d14c47f965b"
  associate_public_ip_address          = true
  iam_instance_profile                 = aws_iam_instance_profile.ecs-asg-nat-instance_profile.name
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t3.nano"
  private_ip                           = "10.6.2.96"
  source_dest_check                    = false
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

  user_data_replace_on_change = true
  vpc_security_group_ids      = [aws_security_group.instance_ecs-asg-nat-instance_group.id]
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
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
      max_price                      = "0.005200"
      spot_instance_type             = "one-time"
    }
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
      Name = "ecs-asg-nat-instance"
    }
  }
  tags = {
    Name           = "ecs-asg-nat-instance"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_launch_template" "ecs-asg-lt" {
  image_id               = "ami-00933d65211588ffa"
  name                   = "ecs-asg-lt"
  description            = "ECS container instances for the ASG (t3.nano, x86_64 -- matches the x86_64 Hub image). user_data joins the ecs-asg-cluster. In private subnets, so they reach ECR/ECS via the NAT."
  instance_type          = "t3.nano"
  update_default_version = true
  user_data = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
ECS_CLUSTER="ecs-asg-cluster"
NAME="ecs-asg-nodes"
REGION="us-west-2"
ACCOUNT="952133486861"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

# --- BEGIN STRUCT8 ECS BOOTSTRAP ---
mkdir -p /etc/ecs
source /etc/struct8_env
echo "ECS_CLUSTER=$ECS_CLUSTER" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_CONTAINER_METADATA=true" >> /etc/ecs/ecs.config
# --- END STRUCT8 ECS BOOTSTRAP ---

echo "ECS_CLUSTER=ecs-asg-cluster" >> /etc/ecs/ecs.config
EOFUData
)
  vpc_security_group_ids = [aws_security_group.autoscaling_group_ecs-asg-nodes_group.id]
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 30
      volume_type           = "gp3"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs-asg-nodes_profile.name
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      AmazonECSManaged = true
      Name             = "ecs-asg-nodes"
      State            = "ecs-asg-state"
      Struct8Creator   = "rmay struct"
    }
  }
  tags = {
    Name           = "ecs-asg-lt"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_autoscaling_group" "ecs-asg-nodes" {
  name                  = "ecs-asg-nodes"
  default_cooldown      = 30
  desired_capacity      = 1
  enabled_metrics       = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  health_check_type     = "EC2"
  max_instance_lifetime = 0
  max_size              = 3
  min_size              = 1
  termination_policies  = ["Default"]
  vpc_zone_identifier   = [aws_subnet.ecs-asg-private-a.id, aws_subnet.ecs-asg-private-b.id]
  availability_zone_distribution {
    capacity_distribution_strategy = "balanced-best-effort"
  }
  capacity_reservation_specification {
    capacity_reservation_preference = "default"
  }
  instance_refresh {
    strategy = "Rolling"
    triggers = ["launch_template"]
    preferences {
      instance_warmup              = "60"
      min_healthy_percentage       = 0
      scale_in_protected_instances = "Ignore"
      standby_instances            = "Ignore"
    }
  }
  launch_template {
    version = "1"
    id      = aws_launch_template.ecs-asg-lt.id
  }
  lifecycle {
    ignore_changes = [desired_capacity]
  }
  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = true
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "ecs-asg-nodes"
  }
  tag {
    key                 = "State"
    propagate_at_launch = true
    value               = "ecs-asg-state"
  }
  tag {
    key                 = "Struct8Creator"
    propagate_at_launch = true
    value               = "rmay struct"
  }
}

resource "aws_appautoscaling_policy" "ecs-asg-hub-cpu" {
  name               = "ecs-asg-hub-cpu"
  resource_id        = aws_appautoscaling_target.ecs-asg-hub-scale.resource_id
  policy_type        = "TargetTrackingScaling"
  scalable_dimension = aws_appautoscaling_target.ecs-asg-hub-scale.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs-asg-hub-scale.service_namespace
  target_tracking_scaling_policy_configuration {
    disable_scale_in   = false
    scale_in_cooldown  = 60
    scale_out_cooldown = 30
    target_value       = 50
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_target" "ecs-asg-hub-scale" {
  resource_id        = "service/${aws_ecs_cluster.ecs-asg-cluster.name}/${aws_ecs_service.ecs-asg-hub_service.name}"
  max_capacity       = 12
  min_capacity       = 1
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  suspended_state {
    dynamic_scaling_in_suspended  = false
    dynamic_scaling_out_suspended = false
    scheduled_scaling_suspended   = false
  }
  tags = {
    Name           = "ecs-asg-hub-scale"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}
