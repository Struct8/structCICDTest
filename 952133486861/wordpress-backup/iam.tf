resource "aws_iam_role" "wpDailyBackup_backup_role" {
  name                  = "wpDailyBackup-hbzliH5R-backup"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"backup.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "wpDailyBackup_backup_role"
    State          = "wordpress-backup"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_kms_alias" "kmsWordpress_cross_state_alias" {
  name          = "alias/kmsWordpress-XefebEei"
  target_key_id = aws_kms_key.kmsWordpress.key_id
}

resource "aws_kms_key" "kmsWordpress" {
  bypass_policy_lockout_safety_check = false
  customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  deletion_window_in_days            = 7
  enable_key_rotation                = true
  is_enabled                         = true
  key_usage                          = "ENCRYPT_DECRYPT"
  multi_region                       = false
  policy                             = "{\"Id\":\"key-default-1\",\"Statement\":[{\"Action\":\"kms:*\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::952133486861:root\"},\"Resource\":\"*\",\"Sid\":\"Enable IAM User Permissions\"}],\"Version\":\"2012-10-17\"}"
  rotation_period_in_days            = 365
  tags = {
    Name           = "kmsWordpress"
    State          = "wordpress-backup"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_secretsmanager_secret" "wpSecrets" {
  kms_key_id                     = aws_kms_key.kmsWordpress.id
  name                           = "wpSecrets"
  description                    = "Password of the WordPress database user. Terraform generates it, and each WordPress task creates or updates that user at startup with the Aurora master credentials."
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 0
  tags = {
    Name           = "wpSecrets"
    State          = "wordpress-backup"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_secretsmanager_secret_version" "wpSecrets_version" {
  secret_id      = aws_secretsmanager_secret.wpSecrets.id
  secret_string  = " "
  version_stages = ["AWSCURRENT"]
  lifecycle {
    ignore_changes = [secret_string]
  }
}
