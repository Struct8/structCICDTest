resource "aws_ssm_parameter" "wpAdminPassword" {
  key_id      = aws_kms_key.kmsWordpress.arn
  name        = "wpAdminPassword"
  data_type   = "text"
  description = "Password of the WordPress administrator created by the first start of the site. Terraform generates it. Changing it here does not change the password in WordPress after the installation."
  overwrite   = false
  tier        = "Standard"
  type        = "SecureString"
  value       = "imported_value_not_managed_here"
  lifecycle {
    ignore_changes = [value]
  }
  tags = {
    Name           = "wpAdminPassword"
    State          = "importBackupLab"
    Struct8Creator = "rmay struct"
  }
}
