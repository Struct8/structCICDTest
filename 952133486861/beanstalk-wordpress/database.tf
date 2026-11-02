resource "aws_db_instance" "wp-eb-db" {
  db_name                     = "wordpress"
  db_subnet_group_name        = aws_db_subnet_group.subnet_group_wp-eb-db.name
  kms_key_id                  = "arn:aws:kms:us-west-2:952133486861:key/e401bcbe-b1b2-4a12-ac7d-cb374176b6fb"
  option_group_name           = "default:mysql-8-4"
  parameter_group_name        = "default.mysql8.4"
  allocated_storage           = 20
  availability_zone           = aws_subnet.wp-data-a.availability_zone
  backup_retention_period     = 0
  backup_window               = "09:20-09:50"
  ca_cert_identifier          = "rds-ca-rsa2048-g1"
  copy_tags_to_snapshot       = true
  database_insights_mode      = "standard"
  engine                      = "mysql"
  engine_lifecycle_support    = "open-source-rds-extended-support-disabled"
  engine_version              = "8.4"
  identifier                  = "wp-eb-db"
  instance_class              = "db.t4g.micro"
  maintenance_window          = "thu:07:44-thu:08:14"
  manage_master_user_password = true
  max_allocated_storage       = 100
  skip_final_snapshot         = true
  storage_encrypted           = true
  storage_type                = "gp3"
  upgrade_storage_config      = false
  username                    = "admin"
  vpc_security_group_ids      = [aws_security_group.db_instance_wp-eb-db_group.id]
  lifecycle {
    ignore_changes = [apply_immediately, upgrade_storage_config, manage_master_user_password, engine_version]
  }
  tags = {
    Name           = "wp-eb-db"
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_db_subnet_group" "subnet_group_wp-eb-db" {
  name       = "wp-eb-db-subnet-group"
  subnet_ids = [aws_subnet.wp-data-a.id, aws_subnet.wp-data-b.id]
  tags = {
    Name           = "subnet_group_wp-eb-db"
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
  }
}
