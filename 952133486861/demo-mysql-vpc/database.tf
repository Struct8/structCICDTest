resource "aws_db_option_group" "demo-mysql-options" {
  engine_name              = "mysql"
  major_engine_version     = "8.4"
  name_prefix              = "demo-mysql-options"
  option_group_description = "MySQL 8.4 option group for the demo, with the MariaDB audit plugin."
  skip_destroy             = false
  lifecycle {
    create_before_destroy = false
  }
  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }
  tags = {
    Name           = "demo-mysql-options"
    State          = "demo-mysql-vpc"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_db_parameter_group" "demo-mysql-params" {
  description  = "MySQL 8.4 parameters for the demo: utf8mb4, connection limit, slow query log and general query log."
  family       = "mysql8.4"
  name_prefix  = "demo-mysql-params"
  skip_destroy = false
  lifecycle {
    create_before_destroy = true
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }
  parameter {
    name  = "max_connections"
    value = "200"
  }
  parameter {
    name  = "slow_query_log"
    value = "1"
  }
  parameter {
    name  = "long_query_time"
    value = "2"
  }
  parameter {
    name  = "general_log"
    value = "1"
  }
  tags = {
    Name           = "demo-mysql-params"
    State          = "demo-mysql-vpc"
    Struct8Creator = "rmay struct"
  }
}
