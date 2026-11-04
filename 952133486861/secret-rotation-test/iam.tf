resource "aws_secretsmanager_secret" "rotation-test-secret-empty" {
  name                           = "rotation-test-secret-empty"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 0
  tags = {
    Name           = "rotation-test-secret-empty"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_secretsmanager_secret" "rotation-test-secret-ignored" {
  name                           = "rotation-test-secret-ignored"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 0
  tags = {
    Name           = "rotation-test-secret-ignored"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_secretsmanager_secret" "rotation-test-secret-plain" {
  name                           = "rotation-test-secret-plain"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 0
  tags = {
    Name           = "rotation-test-secret-plain"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_secretsmanager_secret_version" "rotation-test-secret-ignored_version" {
  secret_id     = aws_secretsmanager_secret.rotation-test-secret-ignored.id
  secret_string = "dummy-initial-secret-ignored"
  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret_version" "rotation-test-secret-plain_version" {
  secret_id     = aws_secretsmanager_secret.rotation-test-secret-plain.id
  secret_string = "dummy-initial-secret-plain"
}
