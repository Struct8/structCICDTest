resource "aws_ssm_parameter" "ssm-ignored" {
  name      = "/rotation-test/ssm-ignored"
  data_type = "text"
  overwrite = true
  tier      = "Standard"
  type      = "SecureString"
  value     = "dummy-initial-ssm-ignored"
  lifecycle {
    ignore_changes = [value]
  }
  tags = {
    Name           = "ssm-ignored"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_ssm_parameter" "ssm-plain" {
  name      = "/rotation-test/ssm-plain"
  data_type = "text"
  overwrite = true
  tier      = "Standard"
  type      = "SecureString"
  value     = "dummy-initial-ssm-plain"
  tags = {
    Name           = "ssm-plain"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}
