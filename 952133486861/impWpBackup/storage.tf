resource "aws_backup_plan" "wpDailyBackup" {
  name = "wpDailyBackup"
  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.wpBackupVault.name
    completion_window = 180
    schedule          = "cron(0 5 * * ? *)"
    start_window      = 60
    lifecycle {
      cold_storage_after                        = 0
      delete_after                              = 35
      opt_in_to_archive_for_supported_resources = false
    }
  }
  tags = {
    Name           = "wpDailyBackup"
    State          = "wordpress-backup"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_backup_selection" "wpDailyBackup_selection" {
  name      = "wpDailyBackup-LG8tjg6d-resources"
  plan_id   = aws_backup_plan.wpDailyBackup.id
  resources = ["arn:aws:elasticfilesystem:*:*:file-system/*", "arn:aws:rds:*:*:cluster:*", "arn:aws:s3:::*"]
  condition {
    string_equals {
      key   = "aws:ResourceTag/Struct8:Backup:wpDailyBackup-LG8tjg6d"
      value = true
    }
  }
  iam_role_arn = aws_iam_role.wpDailyBackup_backup_role.arn
}

resource "aws_backup_vault" "wpBackupVault" {
  name          = "wpBackupVault"
  force_destroy = true
  kms_key_arn   = "arn:aws:kms:us-west-2:952133486861:key/8b02ffe2-5da5-47a8-a549-8bf0fc7400a8"
  tags = {
    Name           = "wpBackupVault"
    State          = "wordpress-backup"
    Struct8Creator = "rmay struct"
  }
}
