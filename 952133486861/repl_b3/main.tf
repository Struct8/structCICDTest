terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/repl_b3/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: IAM ###

resource "aws_iam_policy" "s3_bucket_replication_configuration_primary-replication_st_s3-replication" {
  name        = "s3_bucket_replication_configuration_primary-replication_st_s3-replication"
  description = "Access Policy for primary-replication"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Resource": [
        "${aws_s3_bucket.primary.arn}"
      ],
      "Sid": "AllowReplicationSourceBucketRead"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionTagging"
      ],
      "Resource": [
        "${aws_s3_bucket.primary.arn}/*"
      ],
      "Sid": "AllowReplicationSourceObjectRead"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ReplicateDelete",
        "s3:ReplicateObject",
        "s3:ReplicateTags"
      ],
      "Resource": [
        "${aws_s3_bucket.replica.arn}/*"
      ],
      "Sid": "AllowReplicationDestinationWrite"
    }
  ]
})
}

resource "aws_iam_role" "role_s3_bucket_primary-replication" {
  name                  = "role_s3_bucket_primary-replication"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"s3.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "role_s3_bucket_primary-replication"
    State          = "s3-replication"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "s3_bucket_replication_configuration_primary-replication_st_s3-replication_attach_role_s3_bucket_primary-replication" {
  policy_arn = aws_iam_policy.s3_bucket_replication_configuration_primary-replication_st_s3-replication.arn
  role       = aws_iam_role.role_s3_bucket_primary-replication.name
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "primary" {
  bucket              = "s3-repl-primary-952133486861-us-west-2-an"
  bucket_namespace    = "account-regional"
  object_lock_enabled = false
  tags = {
    Name           = "primary"
    State          = "s3-replication"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket" "replica" {
  bucket              = "s3-repl-replica-952133486861-us-west-2-an"
  bucket_namespace    = "account-regional"
  object_lock_enabled = false
  tags = {
    Name           = "replica"
    State          = "s3-replication"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_ownership_controls" "primary_controls" {
  bucket = aws_s3_bucket.primary.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_ownership_controls" "replica_controls" {
  bucket = aws_s3_bucket.replica.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "primary_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.primary.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "replica_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.replica.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_replication_configuration" "primary-replication" {
  bucket = aws_s3_bucket.primary.id
  role   = aws_iam_role.role_s3_bucket_primary-replication.arn
  rule {
    id       = "replicate-all"
    priority = 0
    status   = "Enabled"
    destination {
      bucket        = aws_s3_bucket.replica.arn
      storage_class = "STANDARD"
    }
  }
  depends_on = [aws_s3_bucket_versioning.primary_versioning, aws_s3_bucket_versioning.replica_versioning, aws_iam_role_policy_attachment.s3_bucket_replication_configuration_primary-replication_st_s3-replication_attach_role_s3_bucket_primary-replication]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "primary_configuration" {
  bucket = aws_s3_bucket.primary.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "replica_configuration" {
  bucket = aws_s3_bucket.replica.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "primary_versioning" {
  bucket = aws_s3_bucket.primary.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "replica_versioning" {
  bucket = aws_s3_bucket.replica.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Enabled"
  }
}


