terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/rdsap_import/main.tfstate"
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

### RENAMES ###

moved {
  from = aws_security_group_rule.rule_demo_postgres_api_1_to_db_proxy_demo_postgres_proxy_group_tcp_5432
  to   = aws_security_group_rule.rule_demo_postgres_api_to_db_proxy_demo_postgres_proxy_group_tcp_5432
}

moved {
  from = aws_security_group_rule.rule_demo_postgres_direct_1_to_db_instance_demo_postgres_group_tcp_5432
  to   = aws_security_group_rule.rule_demo_postgres_direct_to_db_instance_demo_postgres_group_tcp_5432
}

moved {
  from = aws_security_group_rule.rule_demo_postgres_iam_1_to_db_instance_demo_postgres_group_tcp_5432
  to   = aws_security_group_rule.rule_demo_postgres_iam_to_db_instance_demo_postgres_group_tcp_5432
}




### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "demo-pgweb_profile" {
  name = "demo-pgweb_profile"
  path = "/"
  role = aws_iam_role.demo-pgweb_role.name
  tags = {
    Name           = "demo-pgweb_profile"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_policy" "db_proxy_demo-postgres-proxy_st_demo-postgres-state" {
  name        = "db_proxy_demo-postgres-proxy_st_demo-postgres-state"
  description = "Access Policy for demo-postgres-proxy"
  policy = <<EOF
{
  "Statement": [
    {
      "Action": "secretsmanager:GetSecretValue",
      "Effect": "Allow",
      "Resource": "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-042bde99-8d2f-4d78-b1fb-d2e1f0ed03bb-y4PZXu",
      "Sid": "ReadDatabaseCredentials"
    }
  ],
  "Version": "2012-10-17"
}
  EOF
  tags = {
    Name           = "db_proxy_demo-postgres-proxy_st_demo-postgres-state"
    State          = "rdsap_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_policy" "instance_demo-pgweb_st_demo-postgres-state" {
  name        = "instance_demo-pgweb_st_demo-postgres-state"
  description = "Access Policy for demo-pgweb"
  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-042bde99-8d2f-4d78-b1fb-d2e1f0ed03bb-y4PZXu",
      "Sid": "AllowRDSSecretAccessdemopostgres"
    }
  ],
  "Version": "2012-10-17"
}
  EOF
  tags = {
    Name           = "instance_demo-pgweb_st_demo-postgres-state"
    State          = "rdsap_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_policy" "lambda_function_demo-postgres-api_st_demo-postgres-state" {
  name        = "lambda_function_demo-postgres-api_st_demo-postgres-state"
  description = "Access Policy for demo-postgres-api"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.demo-postgres-api-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AssignPrivateIpAddresses",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:UnassignPrivateIpAddresses"
      ],
      "Resource": [
        "*"
      ],
      "Sid": "AllowAllResources"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-042bde99-8d2f-4d78-b1fb-d2e1f0ed03bb-y4PZXu"
      ],
      "Sid": "ReadDatabaseCredentials"
    }
  ]
})
}

resource "aws_iam_policy" "lambda_function_demo-postgres-direct_st_demo-postgres-state" {
  name        = "lambda_function_demo-postgres-direct_st_demo-postgres-state"
  description = "Access Policy for demo-postgres-direct"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.demo-postgres-direct-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AssignPrivateIpAddresses",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:UnassignPrivateIpAddresses"
      ],
      "Resource": [
        "*"
      ],
      "Sid": "AllowAllResources"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-042bde99-8d2f-4d78-b1fb-d2e1f0ed03bb-y4PZXu"
      ],
      "Sid": "AllowRDSSecretAccessdemopostgres"
    }
  ]
})
}

resource "aws_iam_policy" "lambda_function_demo-postgres-iam_st_demo-postgres-state" {
  name        = "lambda_function_demo-postgres-iam_st_demo-postgres-state"
  description = "Access Policy for demo-postgres-iam"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.demo-postgres-iam-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AssignPrivateIpAddresses",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:UnassignPrivateIpAddresses"
      ],
      "Resource": [
        "*"
      ],
      "Sid": "AllowAllResources"
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds-db:connect"
      ],
      "Resource": [
        "arn:aws:rds-db:us-west-2:952133486861:dbuser:db-6SP4PWSMVEKLWTXIGZXGYOEGPU/lambda_iam"
      ],
      "Sid": "RdsIamConnect"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-042bde99-8d2f-4d78-b1fb-d2e1f0ed03bb-y4PZXu"
      ],
      "Sid": "AllowRDSSecretAccessdemopostgres"
    }
  ]
})
}

resource "aws_iam_role" "Struct8Debug-Debug" {
  name                  = "Struct8Debug-Yhne4-LuxV602c2KaZmjp"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::952133486861:role/CrossAccountStruct8\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "Struct8Debug-Debug"
    State          = "rdsap_import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "demo-pgweb_role" {
  name                  = "demo-pgweb_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "demo-pgweb_role"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "demo-postgres-api_role" {
  name                  = "demo-postgres-api_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "demo-postgres-api_role"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "demo-postgres-direct_role" {
  name                  = "demo-postgres-direct_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "demo-postgres-direct_role"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "demo-postgres-iam_role" {
  name                  = "demo-postgres-iam_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "demo-postgres-iam_role"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_monitoring_demo-postgres" {
  name                  = "role_monitoring_demo-postgres"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"monitoring.rds.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "role_monitoring_demo-postgres"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_rds_proxy_demo-postgres-proxy" {
  name                  = "role_rds_proxy_demo-postgres-proxy"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"rds.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "role_rds_proxy_demo-postgres-proxy"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_demo-pgweb_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.demo-pgweb_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_demo-pgweb_profile_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.demo-pgweb_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_demo-postgres-api_st_demo-postgres-state_attach_demo-postgres-api_role" {
  policy_arn = aws_iam_policy.lambda_function_demo-postgres-api_st_demo-postgres-state.arn
  role       = aws_iam_role.demo-postgres-api_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_demo-postgres-direct_st_demo-postgres-state_attach_demo-postgres-direct_role" {
  policy_arn = aws_iam_policy.lambda_function_demo-postgres-direct_st_demo-postgres-state.arn
  role       = aws_iam_role.demo-postgres-direct_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_demo-postgres-iam_st_demo-postgres-state_attach_demo-postgres-iam_role" {
  policy_arn = aws_iam_policy.lambda_function_demo-postgres-iam_st_demo-postgres-state.arn
  role       = aws_iam_role.demo-postgres-iam_role.name
}

resource "aws_iam_role_policy_attachment" "service_role_AmazonRDSEnhancedMonitoringRole_to_demo-postgres_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.role_monitoring_demo-postgres.name
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "rds-access-patterns-lab" {
  cidr_block           = "10.8.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "rds-access-patterns-lab"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_vpc_endpoint" "ep-cloudwatch_LOGS_EC2" {
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ec2"
  vpc_id              = aws_vpc.rds-access-patterns-lab.id
  ip_address_type     = "ipv4"
  policy              = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}]}"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg_vpce_ep-cloudwatch_LOGS.id]
  subnet_ids          = [aws_subnet.demo-postgres-private-a.id, aws_subnet.demo-postgres-private-b.id]
  vpc_endpoint_type   = "Interface"
  tags = {
    Name           = "ep-cloudwatch_LOGS"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
    DifName        = "ep-cloudwatch"
  }
}

resource "aws_vpc_endpoint" "ep-secret-manager_SECRETSMANAGER_EC2" {
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ec2"
  vpc_id              = aws_vpc.rds-access-patterns-lab.id
  ip_address_type     = "ipv4"
  policy              = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}]}"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg_vpce_ep-secret-manager_SECRETSMANAGER.id]
  subnet_ids          = [aws_subnet.demo-postgres-private-a.id, aws_subnet.demo-postgres-private-b.id]
  vpc_endpoint_type   = "Interface"
  tags = {
    Name           = "ep-secret-manager_SECRETSMANAGER"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
    DifName        = "ep-secret-manager"
  }
}

resource "aws_subnet" "demo-postgres-private-a" {
  vpc_id                              = aws_vpc.rds-access-patterns-lab.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.8.0.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "demo-postgres-private-a"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "demo-postgres-private-b" {
  vpc_id                              = aws_vpc.rds-access-patterns-lab.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.8.1.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "demo-postgres-private-b"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "demo-public-a" {
  vpc_id                              = aws_vpc.rds-access-patterns-lab.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.8.10.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "demo-public-a"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.rds-access-patterns-lab.id
  tags = {
    Name           = "demo-igw"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_demo-public-rt_to_demo-igw_ipv4" {
  gateway_id             = aws_internet_gateway.demo-igw.id
  route_table_id         = aws_route_table.demo-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "demo-public-rt" {
  vpc_id = aws_vpc.rds-access-patterns-lab.id
  tags = {
    Name           = "demo-public-rt"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_demo_public_a_demo_public_rt" {
  route_table_id = aws_route_table.demo-public-rt.id
  subnet_id      = aws_subnet.demo-public-a.id
}

resource "aws_security_group" "db_instance_demo-postgres_group" {
  name                   = "db_instance_demo-postgres_group"
  vpc_id                 = aws_vpc.rds-access-patterns-lab.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "db_instance_demo-postgres_group"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "db_proxy_demo-postgres-proxy_group" {
  name                   = "db_proxy_demo-postgres-proxy_group"
  vpc_id                 = aws_vpc.rds-access-patterns-lab.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "db_proxy_demo-postgres-proxy_group"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "demo-postgres-api_1" {
  name                   = "demo-postgres-api"
  vpc_id                 = aws_vpc.rds-access-patterns-lab.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "demo-postgres-api"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "demo-postgres-direct_1" {
  name                   = "demo-postgres-direct"
  vpc_id                 = aws_vpc.rds-access-patterns-lab.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "demo-postgres-direct"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "demo-postgres-iam_1" {
  name                   = "demo-postgres-iam"
  vpc_id                 = aws_vpc.rds-access-patterns-lab.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "demo-postgres-iam"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_demo-pgweb_group" {
  name                   = "instance_demo-pgweb_group"
  vpc_id                 = aws_vpc.rds-access-patterns-lab.id
  description            = "pgweb web UI"
  revoke_rules_on_delete = false
}

resource "aws_security_group" "sg_vpce_ep-cloudwatch" {
  name                   = "vpce-sg-ep-cloudwatch"
  vpc_id                 = aws_vpc.rds-access-patterns-lab.id
  description            = "Auto-generated SG for ep-cloudwatch"
  revoke_rules_on_delete = false
  tags = {
    Name           = "sg_vpce_ep-cloudwatch"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
    DifName        = "ep-cloudwatch"
  }
}

resource "aws_security_group" "sg_vpce_ep-cloudwatch_LOGS" {
  name        = "vpce-sg-ep-cloudwatch_logs"
  vpc_id      = aws_vpc.rds-access-patterns-lab.id
  description = "Auto-generated SG for ep-cloudwatch_LOGS"
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name           = "ep-cloudwatch_LOGS"
    DifName        = "sg_vpce_ep-cloudwatch_LOGS"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "sg_vpce_ep-secret-manager" {
  name                   = "vpce-sg-ep-secret-manager"
  vpc_id                 = aws_vpc.rds-access-patterns-lab.id
  description            = "Auto-generated SG for ep-secret-manager"
  revoke_rules_on_delete = false
  tags = {
    Name           = "sg_vpce_ep-secret-manager"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
    DifName        = "ep-secret-manager"
  }
}

resource "aws_security_group" "sg_vpce_ep-secret-manager_SECRETSMANAGER" {
  name        = "vpce-sg-ep-secret-manager_secretsmanager"
  vpc_id      = aws_vpc.rds-access-patterns-lab.id
  description = "Auto-generated SG for ep-secret-manager_SECRETSMANAGER"
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name           = "ep-secret-manager_SECRETSMANAGER"
    DifName        = "sg_vpce_ep-secret-manager_SECRETSMANAGER"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_db_instance_demo_postgres_group_egress_all_protocols" {
  security_group_id = aws_security_group.db_instance_demo-postgres_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_db_proxy_demo_postgres_proxy_group_egress_all_protocols" {
  security_group_id = aws_security_group.db_proxy_demo-postgres-proxy_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_db_proxy_demo_postgres_proxy_group_to_db_instance_demo_postgres_group_tcp_5432" {
  security_group_id        = aws_security_group.db_instance_demo-postgres_group.id
  source_security_group_id = aws_security_group.db_proxy_demo-postgres-proxy_group.id
  description              = "Allow from RDS Proxy demo-postgres-proxy"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_demo_postgres_api_1_egress_all_protocols" {
  security_group_id = aws_security_group.demo-postgres-api_1.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_demo_postgres_api_to_db_proxy_demo_postgres_proxy_group_tcp_5432" {
  security_group_id        = aws_security_group.db_proxy_demo-postgres-proxy_group.id
  source_security_group_id = aws_security_group.demo-postgres-api_1.id
  description              = "Allow from demo-postgres-api (tcp:5432-5432)"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_demo_postgres_direct_1_egress_all_protocols" {
  security_group_id = aws_security_group.demo-postgres-direct_1.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_demo_postgres_direct_to_db_instance_demo_postgres_group_tcp_5432" {
  security_group_id        = aws_security_group.db_instance_demo-postgres_group.id
  source_security_group_id = aws_security_group.demo-postgres-direct_1.id
  description              = "Allow from demo-postgres-direct (tcp:5432-5432)"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_demo_postgres_iam_1_egress_all_protocols" {
  security_group_id = aws_security_group.demo-postgres-iam_1.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_demo_postgres_iam_to_db_instance_demo_postgres_group_tcp_5432" {
  security_group_id        = aws_security_group.db_instance_demo-postgres_group.id
  source_security_group_id = aws_security_group.demo-postgres-iam_1.id
  description              = "Allow from demo-postgres-iam (tcp:5432-5432)"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_instance_demo_pgweb_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_demo-pgweb_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_demo_pgweb_group_ingress_tcp_8081" {
  security_group_id = aws_security_group.instance_demo-pgweb_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 8081
  protocol          = "tcp"
  to_port           = 8081
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_demo_pgweb_group_to_db_instance_demo_postgres_group_tcp_5432" {
  security_group_id        = aws_security_group.db_instance_demo-postgres_group.id
  source_security_group_id = aws_security_group.instance_demo-pgweb_group.id
  description              = "Allow from instance_demo-pgweb_group (tcp:5432-5432)"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_sg_vpce_ep_cloudwatch_LOGS_egress_all_protocols" {
  security_group_id = aws_security_group.sg_vpce_ep-cloudwatch_LOGS.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_sg_vpce_ep_cloudwatch_LOGS_ingress_tcp_443" {
  security_group_id = aws_security_group.sg_vpce_ep-cloudwatch_LOGS.id
  cidr_blocks       = ["10.8.0.0/16"]
  description       = "Allow HTTPS from VPC"
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_sg_vpce_ep_cloudwatch_egress_all_protocols" {
  security_group_id = aws_security_group.sg_vpce_ep-cloudwatch.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_sg_vpce_ep_cloudwatch_ingress_tcp_443" {
  security_group_id = aws_security_group.sg_vpce_ep-cloudwatch.id
  cidr_blocks       = ["10.8.0.0/16"]
  description       = "Allow HTTPS from VPC"
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_sg_vpce_ep_secret_manager_SECRETSMANAGER_egress_all_protocols" {
  security_group_id = aws_security_group.sg_vpce_ep-secret-manager_SECRETSMANAGER.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_sg_vpce_ep_secret_manager_SECRETSMANAGER_ingress_tcp_443" {
  security_group_id = aws_security_group.sg_vpce_ep-secret-manager_SECRETSMANAGER.id
  cidr_blocks       = ["10.8.0.0/16"]
  description       = "Allow HTTPS from VPC"
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_sg_vpce_ep_secret_manager_egress_all_protocols" {
  security_group_id = aws_security_group.sg_vpce_ep-secret-manager.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_sg_vpce_ep_secret_manager_ingress_tcp_443" {
  security_group_id = aws_security_group.sg_vpce_ep-secret-manager.id
  cidr_blocks       = ["10.8.0.0/16"]
  description       = "Allow HTTPS from VPC"
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
  type              = "ingress"
}




### CATEGORY: DATABASE ###

resource "aws_db_instance" "demo-postgres" {
  db_name                             = "appdb"
  db_subnet_group_name                = aws_db_subnet_group.subnet_group_demo-postgres.name
  domain_iam_role_name                = aws_iam_role.role_monitoring_demo-postgres.name
  kms_key_id                          = "arn:aws:kms:us-west-2:952133486861:key/e401bcbe-b1b2-4a12-ac7d-cb374176b6fb"
  option_group_name                   = "default:postgres-18"
  parameter_group_name                = aws_db_parameter_group.demo-postgres-params1.name
  allocated_storage                   = 20
  availability_zone                   = aws_subnet.demo-postgres-private-a.availability_zone
  backup_retention_period             = 7
  backup_window                       = "03:00-04:00"
  ca_cert_identifier                  = "rds-ca-rsa2048-g1"
  copy_tags_to_snapshot               = true
  database_insights_mode              = "standard"
  delete_automated_backups            = false
  engine                              = "postgres"
  engine_lifecycle_support            = "open-source-rds-extended-support-disabled"
  engine_version                      = "18"
  iam_database_authentication_enabled = true
  identifier                          = "demo-postgres"
  instance_class                      = "db.t3.micro"
  maintenance_window                  = "mon:04:30-mon:05:30"
  manage_master_user_password         = true
  max_allocated_storage               = 100
  monitoring_interval                 = 60
  monitoring_role_arn                 = aws_iam_role.role_monitoring_demo-postgres.arn
  port                                = 5432
  skip_final_snapshot                 = true
  storage_encrypted                   = true
  storage_type                        = "gp3"
  upgrade_storage_config              = false
  username                            = "dbadmin"
  vpc_security_group_ids              = [aws_security_group.db_instance_demo-postgres_group.id]
  s3_import {
    ingestion_role = aws_iam_role.role_monitoring_demo-postgres.arn
  }
  tags = {
    Name           = "demo-postgres"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.service_role_AmazonRDSEnhancedMonitoringRole_to_demo-postgres_attach]
}

resource "aws_db_parameter_group" "demo-postgres-params1" {
  description  = "Parametros PostgreSQL 18 para a demo"
  family       = "postgres18"
  name_prefix  = "demo-postgres-params1"
  skip_destroy = false
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name           = "demo-postgres-params1"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_db_proxy" "demo-postgres-proxy" {
  name                           = "demo-postgres-proxy"
  endpoint_network_type          = "IPV4"
  engine_family                  = "POSTGRESQL"
  require_tls                    = true
  role_arn                       = aws_iam_role.role_rds_proxy_demo-postgres-proxy.arn
  target_connection_network_type = "IPV4"
  vpc_security_group_ids         = [aws_security_group.db_proxy_demo-postgres-proxy_group.id]
  vpc_subnet_ids                 = [aws_subnet.demo-postgres-private-a.id, aws_subnet.demo-postgres-private-b.id]
  auth {
    auth_scheme               = "SECRETS"
    client_password_auth_type = "POSTGRES_SCRAM_SHA_256"
    iam_auth                  = "DISABLED"
    secret_arn                = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-042bde99-8d2f-4d78-b1fb-d2e1f0ed03bb-y4PZXu"
  }
  tags = {
    Name           = "demo-postgres-proxy"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_db_proxy_target" "demo-postgres-proxy_target" {
  db_proxy_name          = aws_db_proxy.demo-postgres-proxy.name
  target_group_name      = "default"
  db_instance_identifier = aws_db_instance.demo-postgres.identifier
}

resource "aws_db_subnet_group" "subnet_group_demo-postgres" {
  name       = "demo-postgres-subnet-group"
  subnet_ids = [aws_subnet.demo-postgres-private-a.id, aws_subnet.demo-postgres-private-b.id]
  tags = {
    Name           = "subnet_group_demo-postgres"
    State          = "rdsap_import"
    Struct8Creator = "rmay struct"
  }
}




### CATEGORY: COMPUTE ###

resource "aws_instance" "demo-pgweb" {
  subnet_id                   = aws_subnet.demo-public-a.id
  ami                         = "ami-0cc098d14c47f965b"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.demo-pgweb_profile.name
  instance_type               = "t3.small"
  private_ip                  = "10.8.10.70"
  user_data = <<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
NAME="demo-pgweb"
REGION="us-west-2"
ACCOUNT="952133486861"
AWS_DB_INSTANCE_NAME_0="demo-postgres"
AWS_DB_INSTANCE_ENGINE_0="postgres"
AWS_DB_INSTANCE_ENDPOINT_0="demo-postgres.c9g6oy6oylb0.us-west-2.rds.amazonaws.com:5432"
AWS_DB_INSTANCE_DB_NAME_0="appdb"
AWS_DB_INSTANCE_SECRET_ARN_0="arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-042bde99-8d2f-4d78-b1fb-d2e1f0ed03bb-y4PZXu"
AWS_DB_INSTANCE_USER_NAME_0="arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-042bde99-8d2f-4d78-b1fb-d2e1f0ed03bb-y4PZXu:username::"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

#!/bin/bash
# pgweb (web PostgreSQL explorer) on Amazon Linux 2023 via Docker.
# Boots Docker, runs sosedoff/pgweb on port 8081, and keeps it connected across
# Secrets Manager password rotations.
#
# Works with BOTH a plain RDS instance (aws_db_instance) and an Aurora cluster
# (aws_rds_cluster). Struct8 writes different env var names depending on which the EC2
# is wired to: AWS_DB_INSTANCE_* for RDS, AWS_RDS_CLUSTER_* for Aurora. This script
# detects whichever set is present, so one asset serves both templates.
#
# Why pgweb and not a heavier client: pgweb opens ALREADY CONNECTED on the database,
# with no login screen, no setup wizard and no credential for the user to type. The
# instance reads the password from Secrets Manager and starts pgweb pointed at the DB.
#
# ROTATION-SAFE. An RDS/Aurora managed master secret is rotated by AWS -- notably once
# right after the cluster is created. pgweb reads the password once at container start,
# so a fixed password goes stale on rotation and pgweb loops on "authentication failed"
# (the Lambdas never see this: they read the secret on every invocation). To stay
# connected, a systemd timer re-reads the secret every minute and recreates the
# container whenever the live password differs from the one the container is running
# with -- so a rotation self-heals within ~1 minute.
#
# It hardcodes nothing about the account. Struct8 writes the connection details to
# /etc/struct8_env when the instance is wired to the database AND "add environment
# variables" is enabled; this script reads them from there.
#
# Variables read from /etc/struct8_env (one set or the other, auto-detected):
#   RDS instance:   AWS_DB_INSTANCE_ENDPOINT_0 (host:port), AWS_DB_INSTANCE_DB_NAME_0,
#                   AWS_DB_INSTANCE_SECRET_ARN_0
#   Aurora cluster: AWS_RDS_CLUSTER_ENDPOINT_0 (host), AWS_RDS_CLUSTER_PORT_0,
#                   AWS_RDS_CLUSTER_DB_NAME_0, AWS_RDS_CLUSTER_SECRET_ARN_0
#   REGION          region, used for the AWS CLI calls (falls back to instance metadata)
LOGFILE="/var/log/user-data.log"
exec >"$LOGFILE" 2>&1
set -x

PGWEB_PORT="$${PGWEB_PORT:-8081}"
PGWEB_IMAGE="$${PGWEB_IMAGE:-sosedoff/pgweb:latest}"
# sslmode for the connection. RDS/Aurora require TLS; "require" encrypts without
# verifying the CA (fine for a demo). Use "verify-full" with a CA bundle in prod.
PG_SSLMODE="$${PG_SSLMODE:-require}"

echo "Updating the system..."
dnf update -y

echo "Installing Docker..."
dnf install -y docker
systemctl enable docker
systemctl start docker

# --- Resolve the connection details ONCE, from /etc/struct8_env --------------------
if [ -f /etc/struct8_env ]; then
  # shellcheck disable=SC1091
  . /etc/struct8_env
fi

# Detect the wire: Aurora cluster first, then plain RDS instance.
if [ -n "$${AWS_RDS_CLUSTER_ENDPOINT_0:-}" ]; then
  DB_HOST="$${AWS_RDS_CLUSTER_ENDPOINT_0}"       # Aurora: host alone
  DB_PORT="$${AWS_RDS_CLUSTER_PORT_0:-5432}"
  DB_NAME="$${AWS_RDS_CLUSTER_DB_NAME_0:-}"
  DB_SECRET_ARN="$${AWS_RDS_CLUSTER_SECRET_ARN_0:-}"
elif [ -n "$${AWS_DB_INSTANCE_ENDPOINT_0:-}" ]; then
  DB_HOST="$${AWS_DB_INSTANCE_ENDPOINT_0}"       # RDS: host:port
  DB_PORT=""
  DB_NAME="$${AWS_DB_INSTANCE_DB_NAME_0:-}"
  DB_SECRET_ARN="$${AWS_DB_INSTANCE_SECRET_ARN_0:-}"
else
  echo "ERROR: /etc/struct8_env has no database endpoint. Wire the instance to the"
  echo "RDS instance or Aurora cluster and enable 'add environment variables'. Aborting."
  exit 1
fi

AWS_REGION="$${REGION:-$(curl -s --max-time 5 http://169.254.169.254/latest/meta-data/placement/region)}"

if [ -z "$DB_HOST" ] || [ -z "$DB_SECRET_ARN" ]; then
  echo "ERROR: /etc/struct8_env has no database endpoint/secret. Aborting."
  exit 1
fi

# Endpoint may be host:port (RDS) or host (Aurora); split off a port if present.
case "$DB_HOST" in
  *:*)
    DB_PORT="$${DB_HOST##*:}"
    DB_HOST="$${DB_HOST%%:*}"
    ;;
esac
DB_PORT="$${DB_PORT:-5432}"

# --- Install the reconcile script and the systemd timer that keeps pgweb connected -
# The reconcile script is the single source of truth for how pgweb is run; the boot
# path just invokes it once, and the timer invokes it every minute afterwards.
mkdir -p /opt/pgweb
cat > /opt/pgweb/pgweb.env <<EOFPGENV
DB_HOST=$${DB_HOST}
DB_PORT=$${DB_PORT}
DB_NAME=$${DB_NAME}
DB_SECRET_ARN=$${DB_SECRET_ARN}
AWS_REGION=$${AWS_REGION}
PGWEB_PORT=$${PGWEB_PORT}
PGWEB_IMAGE=$${PGWEB_IMAGE}
PG_SSLMODE=$${PG_SSLMODE}
EOFPGENV

cat > /opt/pgweb/reconcile.sh <<'EOFRECONCILE'
#!/bin/bash
# Ensures the pgweb container is running with the CURRENT master password. Reads the
# secret, compares with what the running container holds, and recreates it on any
# mismatch (or if it is not running). Idempotent: a no-op when already correct.
set -u
# shellcheck disable=SC1091
. /opt/pgweb/pgweb.env

SECRET_JSON="$(aws secretsmanager get-secret-value \
  --secret-id "$DB_SECRET_ARN" --region "$AWS_REGION" \
  --query SecretString --output text 2>/dev/null)" || exit 0
[ -z "$SECRET_JSON" ] && exit 0

DB_USER="$(printf '%s' "$SECRET_JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin)["username"])')" || exit 0
DB_PASS="$(printf '%s' "$SECRET_JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin)["password"])')" || exit 0
[ -z "$DB_PASS" ] && exit 0

# What is the running container using right now?
CUR_PASS="$(docker inspect pgweb --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null | sed -n 's/^PGWEB_PASS=//p')"
RUNNING="$(docker inspect -f '{{.State.Running}}' pgweb 2>/dev/null || echo false)"

if [ "$RUNNING" = "true" ] && [ "$CUR_PASS" = "$DB_PASS" ]; then
  exit 0   # already correct
fi

echo "$(date -u +%FT%TZ) reconcile: (re)starting pgweb (running=$RUNNING, pass changed=$([ "$CUR_PASS" = "$DB_PASS" ] && echo no || echo yes))"
docker rm -f pgweb >/dev/null 2>&1
# Override the image entrypoint with a shell so $PGWEB_PASS is expanded INSIDE the
# container and never appears in argv/`docker inspect .Args`. Separate flags (not a
# DATABASE_URL): pgweb mis-decodes a percent-encoded password in the URL, so a managed
# secret with /, @, :, |, (, > etc. fails auth when encoded. Raw password avoids that.
docker run -d \
  --name pgweb \
  --restart unless-stopped \
  -p "$${PGWEB_PORT}:8081" \
  -e PGWEB_PASS="$DB_PASS" \
  --entrypoint sh \
  "$PGWEB_IMAGE" \
  -c 'exec pgweb --bind=0.0.0.0 --listen=8081 \
    --host="'"$DB_HOST"'" --port="'"$DB_PORT"'" --user="'"$DB_USER"'" \
    --pass="$PGWEB_PASS" --db="'"$DB_NAME"'" --ssl="'"$PG_SSLMODE"'"'
EOFRECONCILE
chmod +x /opt/pgweb/reconcile.sh

cat > /etc/systemd/system/pgweb-reconcile.service <<'EOFSVC'
[Unit]
Description=Reconcile pgweb container with the current DB master secret
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/opt/pgweb/reconcile.sh
EOFSVC

cat > /etc/systemd/system/pgweb-reconcile.timer <<'EOFTIMER'
[Unit]
Description=Run pgweb reconcile every minute (self-heals on secret rotation)

[Timer]
OnBootSec=15s
OnUnitActiveSec=60s
AccuracySec=10s

[Install]
WantedBy=timers.target
EOFTIMER

systemctl daemon-reload
systemctl enable --now pgweb-reconcile.timer

# Run it once now so pgweb comes up immediately instead of waiting for the first tick.
echo "Starting pgweb on port $${PGWEB_PORT}..."
/opt/pgweb/reconcile.sh

echo "Done. pgweb is starting on port $${PGWEB_PORT}."
echo "Open http://<instance-public-ip>:$${PGWEB_PORT} -- it opens already connected to the database."
echo "A systemd timer re-reads the secret every minute and reconnects pgweb after a rotation."

EOFUData

  vpc_security_group_ids = [aws_security_group.instance_demo-pgweb_group.id]
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
    Name = "demo-pgweb"
  }
  }
  tags = {
    Name           = "demo-pgweb"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
    Struct8Debug   = "Yhne4-LuxV602c2KaZmjp"
  }
}

resource "aws_lambda_function" "demo-postgres-api" {
  function_name                  = "demo-postgres-api"
  architectures                  = ["arm64"]
  description                    = "API Lambda que consome o banco demo-postgres"
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 2000
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.demo-postgres-api_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 30
  environment {
    variables = {
    ACCOUNT                      = "952133486861"
    AWS_DB_PROXY_DB_NAME_0       = "appdb"
    AWS_DB_PROXY_ENDPOINT_0      = "demo-postgres-proxy.proxy-c9g6oy6oylb0.us-west-2.rds.amazonaws.com"
    AWS_DB_PROXY_ENGINE_FAMILY_0 = "POSTGRESQL"
    AWS_DB_PROXY_NAME_0          = "demo-postgres-proxy"
    AWS_DB_PROXY_PORT_0          = "5432"
    AWS_DB_PROXY_SECRET_ARN_0    = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-042bde99-8d2f-4d78-b1fb-d2e1f0ed03bb-y4PZXu"
    NAME                         = "demo-postgres-api"
    REGION                       = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "demo-postgres-api"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
  vpc_config {
    security_group_ids = [aws_security_group.demo-postgres-api_1.id]
    subnet_ids         = [aws_subnet.demo-postgres-private-a.id, aws_subnet.demo-postgres-private-b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_demo-postgres-api_st_demo-postgres-state_attach_demo-postgres-api_role]
}

resource "aws_lambda_function" "demo-postgres-direct" {
  function_name                  = "demo-postgres-direct"
  architectures                  = ["arm64"]
  description                    = "Lambda que acessa o RDS DIRETO (sem proxy), rodando o Struct8 Hub"
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 2000
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.demo-postgres-direct_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 30
  environment {
    variables = {
    ACCOUNT                      = "952133486861"
    AWS_DB_INSTANCE_DB_NAME_0    = "appdb"
    AWS_DB_INSTANCE_ENDPOINT_0   = "demo-postgres.c9g6oy6oylb0.us-west-2.rds.amazonaws.com:5432"
    AWS_DB_INSTANCE_ENGINE_0     = "postgres"
    AWS_DB_INSTANCE_NAME_0       = "demo-postgres"
    AWS_DB_INSTANCE_SECRET_ARN_0 = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-042bde99-8d2f-4d78-b1fb-d2e1f0ed03bb-y4PZXu"
    AWS_DB_INSTANCE_USER_NAME_0  = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-042bde99-8d2f-4d78-b1fb-d2e1f0ed03bb-y4PZXu:username::"
    NAME                         = "demo-postgres-direct"
    REGION                       = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "demo-postgres-direct"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
  vpc_config {
    security_group_ids = [aws_security_group.demo-postgres-direct_1.id]
    subnet_ids         = [aws_subnet.demo-postgres-private-a.id, aws_subnet.demo-postgres-private-b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_demo-postgres-direct_st_demo-postgres-state_attach_demo-postgres-direct_role]
}

resource "aws_lambda_function" "demo-postgres-iam" {
  function_name                  = "demo-postgres-iam"
  architectures                  = ["arm64"]
  description                    = "Lambda que acessa o RDS via IAM database authentication (token, sem senha)"
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 2000
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.demo-postgres-iam_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 30
  environment {
    variables = {
    ACCOUNT                      = "952133486861"
    AWS_DB_INSTANCE_DB_NAME_0    = "appdb"
    AWS_DB_INSTANCE_ENDPOINT_0   = "demo-postgres.c9g6oy6oylb0.us-west-2.rds.amazonaws.com:5432"
    AWS_DB_INSTANCE_ENGINE_0     = "postgres"
    AWS_DB_INSTANCE_IAM_USER_0   = "lambda_iam"
    AWS_DB_INSTANCE_NAME_0       = "demo-postgres"
    AWS_DB_INSTANCE_SECRET_ARN_0 = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-042bde99-8d2f-4d78-b1fb-d2e1f0ed03bb-y4PZXu"
    AWS_DB_INSTANCE_USER_NAME_0  = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-042bde99-8d2f-4d78-b1fb-d2e1f0ed03bb-y4PZXu:username::"
    NAME                         = "demo-postgres-iam"
    REGION                       = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "demo-postgres-iam"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
  vpc_config {
    security_group_ids = [aws_security_group.demo-postgres-iam_1.id]
    subnet_ids         = [aws_subnet.demo-postgres-private-a.id, aws_subnet.demo-postgres-private-b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_demo-postgres-iam_st_demo-postgres-state_attach_demo-postgres-iam_role]
}

resource "aws_lambda_permission" "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-postgres-api" {
  function_name = aws_lambda_function.demo-postgres-api.function_name
  statement_id  = "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-postgres-api6569805376e9b1107c94c4039f"
  principal     = "events.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = aws_cloudwatch_event_rule.every-1-minute.arn
}




### CATEGORY: INTEGRATION ###

resource "aws_cloudwatch_event_rule" "every-1-minute" {
  name                = "every-1-minute"
  schedule_expression = "rate(1 minute)"
  state               = "ENABLED"
  tags = {
    Name           = "every-1-minute"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_event_target" "Target" {
  target_id = "terraform-PHNy0lJ7aJKYrOLvALHAMU2RKp"
  arn       = aws_lambda_function.demo-postgres-direct.arn
  rule      = aws_cloudwatch_event_rule.every-1-minute.name
}

resource "aws_cloudwatch_event_target" "Target1" {
  target_id = "terraform-T6pyBSPM8oWsNFyZfKeWRwJcfJ"
  arn       = aws_lambda_function.demo-postgres-api.arn
  rule      = aws_cloudwatch_event_rule.every-1-minute.name
}

resource "aws_cloudwatch_event_target" "Target2" {
  target_id = "terraform-7XLA375yfXm2sSQrb0nWHbUo7k"
  arn       = aws_lambda_function.demo-postgres-iam.arn
  rule      = aws_cloudwatch_event_rule.every-1-minute.name
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "LogGroup" {
  name              = "/aws/rds/proxy/demo-postgres-proxy"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "LogGroup"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-postgres-api-logs" {
  name              = "/aws/lambda/demo-postgres-api"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "demo-postgres-api-logs"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-postgres-direct-logs" {
  name              = "/aws/lambda/demo-postgres-direct"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "demo-postgres-direct-logs"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-postgres-iam-logs" {
  name              = "/aws/lambda/demo-postgres-iam"
  log_group_class   = "STANDARD"
  retention_in_days = 30
  tags = {
    Name           = "demo-postgres-iam-logs"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-postgres-log1" {
  name              = "RDSOSMetrics"
  log_group_class   = "STANDARD"
  retention_in_days = 30
  tags = {
    Name           = "demo-postgres-log1"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}


