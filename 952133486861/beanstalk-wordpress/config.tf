resource "aws_ssm_parameter" "ebWpAdminPassword" {
  key_id      = "alias/aws/ssm"
  name        = "ebWpAdminPassword"
  data_type   = "text"
  description = "Password of the WordPress administrator created by the first start of the site. Terraform generates it."
  overwrite   = false
  tier        = "Standard"
  type        = "SecureString"
  value       = "imported_value_not_managed_here"
  lifecycle {
    ignore_changes = [value]
  }
  tags = {
    Name           = "ebWpAdminPassword"
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
  }
}
