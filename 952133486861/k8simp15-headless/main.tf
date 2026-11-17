terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket  = "pro112-teste-cicd"
    key     = "952133486861/k8simp15-headless/main.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# --- Extra Providers ---
provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(aws_eks_cluster.k8simp15-cluster.certificate_authority[0].data)
    host                   = aws_eks_cluster.k8simp15-cluster.endpoint
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.k8simp15-cluster.name]
      command     = "aws"
    }
  }
}
provider "kubernetes" {
  cluster_ca_certificate = base64decode(aws_eks_cluster.k8simp15-cluster.certificate_authority[0].data)
  host                   = aws_eks_cluster.k8simp15-cluster.endpoint
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.k8simp15-cluster.name]
    command     = "aws"
  }
}

### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "eks-bcd0f58a-36bb-7825-e6ca-b35cfe57087d" {
  name = "eks-bcd0f58a-36bb-7825-e6ca-b35cfe57087d"
  path = "/"
  tags = {
    Name           = "eks-bcd0f58a-36bb-7825-e6ca-b35cfe57087d"
    State          = "k8simp15-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_iam_role" "k8simp15-cluster-role" {
  name                  = "k8simp15-cluster-role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":[\"sts:AssumeRole\",\"sts:TagSession\"],\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"eks.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp15-cluster-role"
    State          = "k8simp15-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_iam_role" "k8simp15-node-role" {
  name                  = "k8simp15-node-role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp15-node-role"
    State          = "k8simp15-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly_to_k8simp15-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.k8simp15-node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy_to_k8simp15-cluster_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8simp15-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy_to_k8simp15-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.k8simp15-node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy_to_k8simp15-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.k8simp15-node-role.name
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "k8simp15-vpc" {
  cidr_block           = "10.88.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "k8simp15-vpc"
    Project        = "k8s-import-lab"
    State          = "k8simp15-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_subnet" "k8simp15-public-us-west-2a" {
  vpc_id                              = aws_vpc.k8simp15-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.88.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                     = "k8simp15-public-us-west-2a"
    Project                                  = "k8s-import-lab"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/k8simp15-cluster" = "shared"
    State                                    = "k8simp15-headless"
    Struct8Creator                           = "Unknown"
  }
}

resource "aws_subnet" "k8simp15-public-us-west-2b" {
  vpc_id                              = aws_vpc.k8simp15-vpc.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.88.2.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                     = "k8simp15-public-us-west-2b"
    Project                                  = "k8s-import-lab"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/k8simp15-cluster" = "shared"
    State                                    = "k8simp15-headless"
    Struct8Creator                           = "Unknown"
  }
}

resource "aws_internet_gateway" "k8simp15-igw" {
  vpc_id = aws_vpc.k8simp15-vpc.id
  tags = {
    Name           = "k8simp15-igw"
    Project        = "k8s-import-lab"
    State          = "k8simp15-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_route" "route_k8simp15-public-rt_to_k8simp15-igw_ipv4" {
  gateway_id             = aws_internet_gateway.k8simp15-igw.id
  route_table_id         = aws_route_table.k8simp15-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "k8simp15-public-rt" {
  vpc_id = aws_vpc.k8simp15-vpc.id
  tags = {
    Name           = "k8simp15-public-rt"
    Project        = "k8s-import-lab"
    State          = "k8simp15-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_route_table_association" "aws_route_table_association_k8simp15_public_us_west_2a_k8simp15_public_rt" {
  route_table_id = aws_route_table.k8simp15-public-rt.id
  subnet_id      = aws_subnet.k8simp15-public-us-west-2a.id
}

resource "aws_route_table_association" "aws_route_table_association_k8simp15_public_us_west_2b_k8simp15_public_rt" {
  route_table_id = aws_route_table.k8simp15-public-rt.id
  subnet_id      = aws_subnet.k8simp15-public-us-west-2b.id
}

resource "aws_security_group" "eks-cluster-sg-k8simp15-cluster-1882100489" {
  name        = "eks-cluster-sg-k8simp15-cluster-1882100489"
  vpc_id      = aws_vpc.k8simp15-vpc.id
  description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name                                     = "eks-cluster-sg-k8simp15-cluster-1882100489"
    "kubernetes.io/cluster/k8simp15-cluster" = "owned"
    State                                    = "k8simp15-headless"
    Struct8Creator                           = "Unknown"
  }
}

resource "aws_security_group" "k8simp15-db-sg" {
  name        = "k8simp15-db-sg"
  vpc_id      = aws_vpc.k8simp15-vpc.id
  description = "k8simp15 PostgreSQL"
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name           = "k8simp15-db-sg"
    Project        = "k8s-import-lab"
    State          = "k8simp15-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp15_cluster_1882100489_egress_all_protocols_from_0_0_0_0_0" {
  security_group_id = aws_security_group.eks-cluster-sg-k8simp15-cluster-1882100489.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp15_cluster_1882100489_egress_all_protocols_from_self" {
  security_group_id = aws_security_group.eks-cluster-sg-k8simp15-cluster-1882100489.id
  description       = "Allows EFA traffic, which is not matched by CIDR rules."
  from_port         = 0
  protocol          = "-1"
  self              = true
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp15_cluster_1882100489_ingress_all_protocols" {
  security_group_id = aws_security_group.eks-cluster-sg-k8simp15-cluster-1882100489.id
  description       = "Allows EFA traffic, which is not matched by CIDR rules."
  from_port         = 0
  protocol          = "-1"
  self              = true
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp15_cluster_1882100489_to_k8simp15_db_sg_tcp_5432" {
  security_group_id        = aws_security_group.k8simp15-db-sg.id
  source_security_group_id = aws_security_group.eks-cluster-sg-k8simp15-cluster-1882100489.id
  description              = "EKS nodes"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_k8simp15_db_sg_egress_all_protocols" {
  security_group_id = aws_security_group.k8simp15-db-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}




### CATEGORY: DATABASE ###

resource "aws_db_instance" "k8simp15-pg" {
  db_subnet_group_name    = aws_db_subnet_group.subnet_group_k8simp15-pg.name
  option_group_name       = "default:postgres-18"
  parameter_group_name    = "default.postgres18"
  allocated_storage       = 20
  availability_zone       = aws_subnet.k8simp15-public-us-west-2a.availability_zone
  backup_retention_period = 0
  backup_window           = "10:49-11:19"
  ca_cert_identifier      = "rds-ca-rsa2048-g1"
  database_insights_mode  = "standard"
  engine                  = "postgres"
  engine_version          = "18.3"
  identifier              = "k8simp15-pg"
  instance_class          = "db.t4g.micro"
  maintenance_window      = "tue:11:34-tue:12:04"
  port                    = 5432
  skip_final_snapshot     = true
  storage_type            = "gp3"
  username                = "labadmin"
  vpc_security_group_ids  = [aws_security_group.eks-cluster-sg-k8simp15-cluster-1882100489.id, aws_security_group.k8simp15-db-sg.id]
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp15-pg"
    State          = "k8simp15-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_db_subnet_group" "subnet_group_k8simp15-pg" {
  name       = "k8simp15-pg-subnets"
  subnet_ids = [aws_subnet.k8simp15-public-us-west-2a.id, aws_subnet.k8simp15-public-us-west-2b.id]
  tags = {
    Name           = "subnet_group_k8simp15-pg"
    State          = "k8simp15-headless"
    Struct8Creator = "Unknown"
  }
}




### CATEGORY: COMPUTE ###

resource "aws_launch_template" "eks-bcd0f58a-36bb-7825-e6ca-b35cfe57087d" {
  image_id        = "ami-00b78a1637f77b388"
  name            = "eks-bcd0f58a-36bb-7825-e6ca-b35cfe57087d"
  default_version = 1
  instance_type   = "m5.large"
  user_data = base64encode(trimsuffix(<<-EOFUData
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    apiServerEndpoint: https://B30BE2FDB525BBF22E28CA761BB39D72.gr7.us-west-2.eks.amazonaws.com
    certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURNakNDQWhxZ0F3SUJBZ0lSQVAyOVdDK211TFg0ZnlRYlMzQ0ZsRmN3RFFZSktvWklodmNOQVFFTEJRQXcKSnpFUU1BNEdBMVVFQ2hNSFFWZFRJRVZMVXpFVE1CRUdBMVVFQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TmpFeApNVGN4T1RRME5ERmFGdzB6TVRFeE1UWXhPVFEwTkRGYU1DY3hFREFPQmdOVkJBb1RCMEZYVXlCRlMxTXhFekFSCkJnTlZCQU1UQ210MVltVnlibVYwWlhNd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3Z2dFS0FvSUIKQVFDdFo2b0h5Y2UzMjZIdVVqM0swZFFqc2UraW5uMXczTmhCQXBkWmNmZFZmQUJCTU1lWUFGelNaUStMcjVYagpCNk90YlluSTc0djdxV2FhNGpwUW1WdS9zZWdRQVBKOGQ3Uzl5WHMxbzNEM3l1RlBPS2RIM0IvUktucGhvZGpYCmZpcE5QcGR2TktMOXdvQkFoQkJQQ2l1WDluMWNpNGNvcHoybnVQQTltelR0WDRQSENzZjdoa1grVkg1d2Nka2wKamJ1bDBVSUN1TENIRzg2dno4RW92aDlHRmZrTHJ3S1VKYkt6cFBYZldtMmZQWUwyc0lyYk5wRnNXQTVpNjJqSQp5VXYzOU5LaHZSQXhXYis2UFdiT2QzZHRPS0t4Y0RMcXV0TjlGYyt3MmVyNWVkaW9kbzZCRm56ZEN5bGpvbGdkCm9QQmNOcy9NMU1mV21Dd0NaYVRxWldtcEFnTUJBQUdqV1RCWE1BNEdBMVVkRHdFQi93UUVBd0lDcERBUEJnTlYKSFJNQkFmOEVCVEFEQVFIL01CMEdBMVVkRGdRV0JCUVV0bk8wZmM1b2ZxVHpub2xnSHpHcGNmN1E5REFWQmdOVgpIUkVFRGpBTWdncHJkV0psY201bGRHVnpNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUJwTGEvdUk2aWdMZEFpCnFrVFNaam05MGZlK0w4T2c4WEFnNkVPTnRyZVd6WTRJdStqbkR6QXJMbzA0c3NtY01hK0FhVU9zengwWXVtckIKaU04bEw4cUVPSTdHU0w0cFBhaUsrOGpKTDF2MHpacHUyd3Q5Sm5CZWVFNVEzMzdNKzNCeUYwWmI4SnNhQ2NpUQo5TnBUMU5YYXljR25NY1M5Sy93Q0ZBdFBrZFRLYnFISTJQRmUwbTl0THFmR1NaUCs3am0zTjFEVWc1UjJYUDA5ClRhenVFY2lrQ25QOXdWajBxTGZuakpVcDVzSFdXRUdnRXpwSVdITjFNOERML3FqNzQvN3JTRkFzZXoyc1VwNjYKeTVjRmNlQXRGRldwZDJBVDBFWkFFYTd3QVMyUjF2ZUZJK1FQN3FyR0JqZWlERWo4bjF6UC9PSEdhVUhpNmxuTQpob0NsVzd3ZgotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    cidr: 172.20.0.0/16
    name: k8simp15-cluster
  kubelet:
    config:
      maxPods: 29
      clusterDNS:
      - 172.20.0.10
    flags:
    - "--node-labels=eks.amazonaws.com/nodegroup-image=ami-00b78a1637f77b388,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=k8simp15-ng"

--//--
EOFUData
, "\n"))
  vpc_security_group_ids = [aws_security_group.eks-cluster-sg-k8simp15-cluster-1882100489.id]
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = 20
      volume_type           = "gp3"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.eks-bcd0f58a-36bb-7825-e6ca-b35cfe57087d.name
  }
  metadata_options {
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  network_interfaces {
    device_index       = 0
    ipv4_address_count = 0
    ipv4_prefix_count  = 0
    ipv6_address_count = 0
    ipv6_prefix_count  = 0
    network_card_index = 0
    security_groups    = aws_security_group.eks-cluster-sg-k8simp15-cluster-1882100489.id
  }
  tags = {
    "eks:cluster-name"   = "k8simp15-cluster"
    "eks:nodegroup-name" = "k8simp15-ng"
    Name                 = "eks-bcd0f58a-36bb-7825-e6ca-b35cfe57087d"
    State                = "k8simp15-headless"
    Struct8Creator       = "Unknown"
  }
}




### CATEGORY: CONTAINERS ###

resource "aws_eks_addon" "eks-pod-identity-agent" {
  addon_name    = "eks-pod-identity-agent"
  cluster_name  = "k8simp15-cluster"
  addon_version = "v1.4.1-eksbuild.3"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "eks-pod-identity-agent"
    State          = "k8simp15-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_eks_cluster" "k8simp15-cluster" {
  version                       = "1.37"
  name                          = "k8simp15-cluster"
  bootstrap_self_managed_addons = true
  deletion_protection           = false
  role_arn                      = aws_iam_role.k8simp15-cluster-role.arn
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "172.20.0.0/16"
    elastic_load_balancing {
      enabled = false
    }
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp15-cluster"
    State          = "k8simp15-headless"
    Struct8Creator = "Unknown"
  }
  upgrade_policy {
    support_type = "EXTENDED"
  }
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = [aws_subnet.k8simp15-public-us-west-2a.id, aws_subnet.k8simp15-public-us-west-2b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy_to_k8simp15-cluster_attach]
}

resource "aws_eks_node_group" "k8simp15-ng" {
  cluster_name    = aws_eks_cluster.k8simp15-cluster.name
  node_group_name = "k8simp15-ng"
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND"
  instance_types  = ["m5.large"]
  node_role_arn   = aws_iam_role.k8simp15-node-role.arn
  subnet_ids      = [aws_subnet.k8simp15-public-us-west-2a.id, aws_subnet.k8simp15-public-us-west-2b.id]
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp15-ng"
    State          = "k8simp15-headless"
    Struct8Creator = "Unknown"
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [aws_route_table_association.aws_route_table_association_k8simp15_public_us_west_2a_k8simp15_public_rt, aws_route.route_k8simp15-public-rt_to_k8simp15-igw_ipv4, aws_route_table_association.aws_route_table_association_k8simp15_public_us_west_2b_k8simp15_public_rt, aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_to_k8simp15-ng_attach, aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_to_k8simp15-ng_attach, aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_to_k8simp15-ng_attach]
}


