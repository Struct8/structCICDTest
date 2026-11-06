data "aws_resourcegroupstaggingapi_resources" "option_group_demo-mysql-options" {
  resource_type_filters = ["rds:og"]
  lifecycle {
    postcondition {
      condition     = length(self.resource_tag_mapping_list) > 0
      error_message = "No RDS option group tagged Name=demo-mysql-options exists in this region. Apply the state that creates it before this one."
    }
    postcondition {
      condition     = length(self.resource_tag_mapping_list) < 2
      error_message = "More than one RDS option group is tagged Name=demo-mysql-options in this region, and this state cannot tell which one to use. Leave one group with that name."
    }
  }
  tag_filter {
    key    = "Name"
    values = ["demo-mysql-options"]
  }
}

data "aws_resourcegroupstaggingapi_resources" "parameter_group_demo-mysql-params" {
  resource_type_filters = ["rds:pg"]
  lifecycle {
    postcondition {
      condition     = length(self.resource_tag_mapping_list) > 0
      error_message = "No RDS DB parameter group tagged Name=demo-mysql-params exists in this region. Apply the state that creates it before this one."
    }
    postcondition {
      condition     = length(self.resource_tag_mapping_list) < 2
      error_message = "More than one RDS DB parameter group is tagged Name=demo-mysql-params in this region, and this state cannot tell which one to use. Leave one group with that name."
    }
  }
  tag_filter {
    key    = "Name"
    values = ["demo-mysql-params"]
  }
}

resource "aws_db_instance" "demo-mysql" {
  db_name                         = "appdb"
  db_subnet_group_name            = aws_db_subnet_group.subnet_group_demo-mysql.name
  kms_key_id                      = data.aws_kms_key.demo-mysql-kms.arn
  option_group_name               = element(split(":", data.aws_resourcegroupstaggingapi_resources.option_group_demo-mysql-options.resource_tag_mapping_list[0].resource_arn), 6)
  parameter_group_name            = element(split(":", data.aws_resourcegroupstaggingapi_resources.parameter_group_demo-mysql-params.resource_tag_mapping_list[0].resource_arn), 6)
  allocated_storage               = 20
  availability_zone               = aws_subnet.demo-mysql-private-a.availability_zone
  backup_retention_period         = 7
  backup_window                   = "03:00-04:00"
  copy_tags_to_snapshot           = true
  enabled_cloudwatch_logs_exports = ["error", "slowquery", "audit", "general"]
  engine                          = "mysql"
  engine_lifecycle_support        = "open-source-rds-extended-support-disabled"
  engine_version                  = "8.4"
  identifier                      = "demo-mysql"
  instance_class                  = "db.t4g.micro"
  maintenance_window              = "mon:04:30-mon:05:30"
  manage_master_user_password     = true
  max_allocated_storage           = 100
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.role_monitoring_demo-mysql.arn
  skip_final_snapshot             = true
  storage_encrypted               = true
  storage_type                    = "gp3"
  upgrade_storage_config          = false
  username                        = "dbadmin"
  vpc_security_group_ids          = [aws_security_group.db_instance_demo-mysql_group.id]
  tags = {
    Name           = "demo-mysql"
    State          = "rds-main"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_cloudwatch_log_group.mysql-logs-error, aws_cloudwatch_log_group.mysql-logs-slowquery, aws_cloudwatch_log_group.mysql-logs-audit, aws_cloudwatch_log_group.mysql-logs-general, aws_cloudwatch_log_group.mysql-logs-monitoring, aws_iam_role_policy_attachment.service_role_AmazonRDSEnhancedMonitoringRole_to_demo-mysql_attach]
}

resource "aws_db_subnet_group" "subnet_group_demo-mysql" {
  name       = "demo-mysql-subnet-group"
  subnet_ids = [aws_subnet.demo-mysql-private-a.id, aws_subnet.demo-mysql-private-b.id]
  tags = {
    Name           = "subnet_group_demo-mysql"
    State          = "rds-main"
    Struct8Creator = "rmay struct"
  }
}
