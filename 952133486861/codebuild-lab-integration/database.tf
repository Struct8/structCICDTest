resource "aws_db_instance" "codebuild-lab-orders-db" {
  db_name                     = "orders"
  db_subnet_group_name        = aws_db_subnet_group.subnet_group_codebuild-lab-orders-db.name
  kms_key_id                  = "arn:aws:kms:us-west-2:952133486861:key/e401bcbe-b1b2-4a12-ac7d-cb374176b6fb"
  option_group_name           = "default:postgres-16"
  parameter_group_name        = "default.postgres16"
  allocated_storage           = 20
  availability_zone           = aws_subnet.codebuild-lab-db-a.availability_zone
  backup_retention_period     = 0
  backup_window               = "07:44-08:14"
  ca_cert_identifier          = "rds-ca-rsa2048-g1"
  copy_tags_to_snapshot       = true
  database_insights_mode      = "standard"
  delete_automated_backups    = false
  engine                      = "postgres"
  engine_lifecycle_support    = "open-source-rds-extended-support-disabled"
  engine_version              = "16"
  identifier                  = "codebuild-lab-orders-db"
  instance_class              = "db.t4g.micro"
  maintenance_window          = "mon:09:28-mon:09:58"
  manage_master_user_password = true
  max_allocated_storage       = 100
  port                        = 5432
  skip_final_snapshot         = true
  storage_encrypted           = true
  storage_type                = "gp3"
  upgrade_storage_config      = false
  username                    = "orders"
  vpc_security_group_ids      = [aws_security_group.db_instance_codebuild-lab-orders-db_group.id]
  tags = {
    Name           = "codebuild-lab-orders-db"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_db_subnet_group" "subnet_group_codebuild-lab-orders-db" {
  name       = "codebuild-lab-orders-db-subnet-group"
  subnet_ids = [aws_subnet.codebuild-lab-db-a.id, aws_subnet.codebuild-lab-db-b.id]
  tags = {
    Name           = "subnet_group_codebuild-lab-orders-db"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}
