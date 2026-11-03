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

resource "aws_vpc_endpoint" "ep-cloudwatch_LOGS" {
  service_name        = "com.amazonaws.${data.aws_region.current.region}.logs"
  vpc_id              = aws_vpc.rds-access-patterns-lab.id
  ip_address_type     = "ipv4"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg_vpce_ep-cloudwatch.id]
  subnet_ids          = [aws_subnet.demo-postgres-private-b.id, aws_subnet.demo-postgres-private-a.id]
  vpc_endpoint_type   = "Interface"
  tags = {
    Name           = "ep-cloudwatch"
    DifName        = "ep-cloudwatch_LOGS"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_vpc_endpoint" "ep-secret-manager_SECRETSMANAGER" {
  service_name        = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
  vpc_id              = aws_vpc.rds-access-patterns-lab.id
  ip_address_type     = "ipv4"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg_vpce_ep-secret-manager.id]
  subnet_ids          = [aws_subnet.demo-postgres-private-b.id, aws_subnet.demo-postgres-private-a.id]
  vpc_endpoint_type   = "Interface"
  tags = {
    Name           = "ep-secret-manager"
    DifName        = "ep-secret-manager_SECRETSMANAGER"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "demo-postgres-private-a" {
  vpc_id                  = aws_vpc.rds-access-patterns-lab.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.8.0.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "demo-postgres-private-a"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "demo-postgres-private-b" {
  vpc_id                  = aws_vpc.rds-access-patterns-lab.id
  availability_zone       = "us-east-1b"
  cidr_block              = "10.8.1.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "demo-postgres-private-b"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "demo-public-a" {
  vpc_id                  = aws_vpc.rds-access-patterns-lab.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.8.10.0/24"
  map_public_ip_on_launch = true
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
  revoke_rules_on_delete = false
  tags = {
    Name           = "db_proxy_demo-postgres-proxy_group"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "demo-postgres-api" {
  name                   = "demo-postgres-api"
  vpc_id                 = aws_vpc.rds-access-patterns-lab.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "demo-postgres-api"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "demo-postgres-direct" {
  name                   = "demo-postgres-direct"
  vpc_id                 = aws_vpc.rds-access-patterns-lab.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "demo-postgres-direct"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "demo-postgres-iam" {
  name                   = "demo-postgres-iam"
  vpc_id                 = aws_vpc.rds-access-patterns-lab.id
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
  name        = "vpce-sg-ep-cloudwatch"
  vpc_id      = aws_vpc.rds-access-patterns-lab.id
  description = "Auto-generated SG for ep-cloudwatch"
  tags = {
    Name           = "ep-cloudwatch"
    DifName        = "sg_vpce_ep-cloudwatch"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "sg_vpce_ep-secret-manager" {
  name        = "vpce-sg-ep-secret-manager"
  vpc_id      = aws_vpc.rds-access-patterns-lab.id
  description = "Auto-generated SG for ep-secret-manager"
  tags = {
    Name           = "ep-secret-manager"
    DifName        = "sg_vpce_ep-secret-manager"
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

resource "aws_security_group_rule" "rule_demo_postgres_api_egress_all_protocols" {
  security_group_id = aws_security_group.demo-postgres-api.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_demo_postgres_api_to_db_proxy_demo_postgres_proxy_group_tcp_5432" {
  security_group_id        = aws_security_group.db_proxy_demo-postgres-proxy_group.id
  source_security_group_id = aws_security_group.demo-postgres-api.id
  description              = "Allow from demo-postgres-api (tcp:5432-5432)"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_demo_postgres_direct_egress_all_protocols" {
  security_group_id = aws_security_group.demo-postgres-direct.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_demo_postgres_direct_to_db_instance_demo_postgres_group_tcp_5432" {
  security_group_id        = aws_security_group.db_instance_demo-postgres_group.id
  source_security_group_id = aws_security_group.demo-postgres-direct.id
  description              = "Allow from demo-postgres-direct (tcp:5432-5432)"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_demo_postgres_iam_egress_all_protocols" {
  security_group_id = aws_security_group.demo-postgres-iam.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_demo_postgres_iam_to_db_instance_demo_postgres_group_tcp_5432" {
  security_group_id        = aws_security_group.db_instance_demo-postgres_group.id
  source_security_group_id = aws_security_group.demo-postgres-iam.id
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
