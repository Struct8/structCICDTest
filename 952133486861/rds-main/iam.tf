resource "aws_iam_role" "role_monitoring_demo-mysql" {
  name = "role_monitoring_demo-mysql"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "monitoring.rds.amazonaws.com"
      }
    }
  ]
})
  tags = {
    Name           = "role_monitoring_demo-mysql"
    State          = "rds-main"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "service_role_AmazonRDSEnhancedMonitoringRole_to_demo-mysql_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.role_monitoring_demo-mysql.name
}
