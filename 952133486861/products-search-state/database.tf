resource "aws_db_subnet_group" "subnet_group_products-aurora" {
  name       = "products-aurora-subnet-group"
  subnet_ids = [aws_subnet.private-a.id, aws_subnet.private-b.id]
  tags = {
    Name           = "subnet_group_products-aurora"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_rds_cluster" "products-aurora" {
  database_name                   = "produtos"
  db_cluster_parameter_group_name = "default.aurora-postgresql17"
  db_subnet_group_name            = aws_db_subnet_group.subnet_group_products-aurora.name
  kms_key_id                      = "arn:aws:kms:us-west-2:952133486861:key/e401bcbe-b1b2-4a12-ac7d-cb374176b6fb"
  apply_immediately               = true
  backup_retention_period         = 7
  cluster_identifier              = "products-aurora"
  copy_tags_to_snapshot           = true
  database_insights_mode          = "standard"
  enable_http_endpoint            = true
  engine                          = "aurora-postgresql"
  engine_lifecycle_support        = "open-source-rds-extended-support"
  engine_version                  = "17.9"
  manage_master_user_password     = true
  master_username                 = "dbadmin"
  network_type                    = "IPV4"
  port                            = 5432
  preferred_backup_window         = "09:25-09:55"
  preferred_maintenance_window    = "tue:10:31-tue:11:01"
  skip_final_snapshot             = true
  storage_encrypted               = true
  vpc_security_group_ids          = [aws_security_group.rds_cluster_products-aurora_group.id]
  serverlessv2_scaling_configuration {
    max_capacity             = 4
    min_capacity             = 0
    seconds_until_auto_pause = 300
  }
  tags = {
    Name           = "products-aurora"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_rds_cluster_instance" "products-aurora-instance" {
  db_parameter_group_name      = "default.aurora-postgresql17"
  ca_cert_identifier           = "rds-ca-rsa2048-g1"
  cluster_identifier           = aws_rds_cluster.products-aurora.id
  copy_tags_to_snapshot        = true
  engine                       = aws_rds_cluster.products-aurora.engine
  identifier                   = "products-aurora-instance"
  instance_class               = "db.serverless"
  preferred_backup_window      = "09:25-09:55"
  preferred_maintenance_window = "thu:11:30-thu:12:00"
  promotion_tier               = 1
  tags = {
    Name           = "products-aurora-instance"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}
