resource "aws_iam_role" "wpDailyBackup_backup_role" {
  name                  = "wpDailyBackup-NBdWLPOf-backup"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"backup.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "wpDailyBackup_backup_role"
    State          = "impWpBackup"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "wpDailyBackup_backup_role_backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.wpDailyBackup_backup_role.name
}

resource "aws_iam_role_policy_attachment" "wpDailyBackup_backup_role_restores" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.wpDailyBackup_backup_role.name
}

resource "aws_iam_role_policy_attachment" "wpDailyBackup_backup_role_s3_backup" {
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
  role       = aws_iam_role.wpDailyBackup_backup_role.name
}

resource "aws_iam_role_policy_attachment" "wpDailyBackup_backup_role_s3_restore" {
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
  role       = aws_iam_role.wpDailyBackup_backup_role.name
}

resource "aws_kms_alias" "kmsWordpress_cross_state_alias" {
  name          = "alias/kmsWordpress--A6hBC1m"
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
    State          = "impWpBackup"
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
    State          = "impWpBackup"
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
