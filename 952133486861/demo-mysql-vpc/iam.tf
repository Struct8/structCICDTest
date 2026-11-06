resource "aws_kms_alias" "demo-mysql-kms_cross_state_alias" {
  name          = "alias/demo-mysql-kms-zJaiUYhB"
  target_key_id = aws_kms_key.demo-mysql-kms.key_id
}

resource "aws_kms_key" "demo-mysql-kms" {
  bypass_policy_lockout_safety_check = false
  customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  deletion_window_in_days            = 30
  description                        = "Encrypts the storage of the demo RDS databases and their snapshot."
  enable_key_rotation                = true
  is_enabled                         = true
  key_usage                          = "ENCRYPT_DECRYPT"
  multi_region                       = false
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
  EOF
  rotation_period_in_days = 365
  tags = {
    Name           = "demo-mysql-kms"
    State          = "demo-mysql-vpc"
    Struct8Creator = "rmay struct"
  }
}
