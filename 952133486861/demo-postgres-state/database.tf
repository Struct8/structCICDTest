resource "aws_db_instance" "demo-postgres" {
  db_name                             = "appdb"
  db_subnet_group_name                = aws_db_subnet_group.subnet_group_demo-postgres.name
  domain_iam_role_name                = aws_iam_role.role_monitoring_demo-postgres.name
  kms_key_id                          = "arn:aws:kms:us-east-1:952133486861:key/e7e0addd-41d3-4784-adce-43cbd5e882b6"
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
    secret_arn                = "arn:aws:secretsmanager:us-east-1:952133486861:secret:rds!db-adc6ba91-46d0-4b10-8666-59a8d723e51f-Lb8Jr4"
  }
  tags = {
    Name           = "demo-postgres-proxy"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_cloudwatch_log_group.LogGroup, aws_iam_role_policy_attachment.db_proxy_demo-postgres-proxy_st_demo-postgres-state_attach]
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
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}
