resource "aws_db_instance" "wp-eb-db" {
  db_name                     = "wordpress"
  db_subnet_group_name        = aws_db_subnet_group.subnet_group_wp-eb-db.name
  kms_key_id                  = "arn:aws:kms:us-east-1:952133486861:key/e7e0addd-41d3-4784-adce-43cbd5e882b6"
  option_group_name           = "default:mariadb-11-4"
  parameter_group_name        = "default.mariadb11.4"
  allocated_storage           = 20
  availability_zone           = aws_subnet.wp-data-a.availability_zone
  backup_retention_period     = 0
  backup_window               = "05:31-06:01"
  ca_cert_identifier          = "rds-ca-rsa2048-g1"
  copy_tags_to_snapshot       = true
  database_insights_mode      = "standard"
  engine                      = "mariadb"
  engine_version              = "11.4"
  identifier                  = "wp-eb-db"
  instance_class              = "db.t4g.micro"
  maintenance_window          = "sun:10:30-sun:11:00"
  manage_master_user_password = true
  max_allocated_storage       = 100
  skip_final_snapshot         = true
  storage_encrypted           = true
  storage_type                = "gp3"
  upgrade_storage_config      = false
  username                    = "admin"
  vpc_security_group_ids      = [aws_security_group.db_instance_wp-eb-db_group.id]
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
