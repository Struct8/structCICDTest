resource "aws_ssm_parameter" "hub-param" {
  name        = "hub-param"
  data_type   = "text"
  description = "Destination parameter for the messages this workload forwards. Each delivery overwrites the value, so a read returns the message that arrived last."
  overwrite   = false
  tier        = "Standard"
  type        = "String"
  value       = "defaultValue"
  lifecycle {
    ignore_changes = [overwrite, value]
  }
  tags = {
    Name           = "hub-param"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}
