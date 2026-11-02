resource "aws_s3_bucket" "beanstalk-wordpress-versions" {
  bucket              = "beanstalk-wordpress-versions-952133486861-us-west-2-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "beanstalk-wordpress-versions"
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_ownership_controls" "beanstalk-wordpress-versions_controls" {
  bucket = aws_s3_bucket.beanstalk-wordpress-versions.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "beanstalk-wordpress-versions_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.beanstalk-wordpress-versions.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "beanstalk-wordpress-versions_configuration" {
  bucket = aws_s3_bucket.beanstalk-wordpress-versions.id
  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "beanstalk-wordpress-versions_versioning" {
  bucket = aws_s3_bucket.beanstalk-wordpress-versions.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}

resource "aws_efs_access_point" "ap_beanstalk-wordpress-web_wp-eb-files" {
  file_system_id = aws_efs_file_system.wp-eb-files.id
  posix_user {
    gid = 33
    uid = 33
  }
  root_directory {
    path = "/beanstalk-wordpress-web"
    creation_info {
      owner_gid   = 33
      owner_uid   = 33
      permissions = "0755"
    }
  }
  tags = {
    Name           = "ap_beanstalk-wordpress-web_wp-eb-files"
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_efs_file_system" "wp-eb-files" {
  kms_key_id      = "arn:aws:kms:us-west-2:952133486861:key/081d3c6c-ad92-4c90-93bf-5939d005aeb1"
  creation_token  = "terraform-SHfTXjsgiInCXgwadcniAR7DZ2"
  encrypted       = true
  throughput_mode = "elastic"
  protection {
    replication_overwrite = "ENABLED"
  }
  tags = {
    Name           = "wp-eb-files"
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_efs_mount_target" "mt_wp-eb-files_wp-data-a" {
  file_system_id  = aws_efs_file_system.wp-eb-files.id
  subnet_id       = aws_subnet.wp-data-a.id
  security_groups = [aws_security_group.efs_file_system_wp-eb-files_group.id]
}

resource "aws_efs_mount_target" "mt_wp-eb-files_wp-data-b" {
  file_system_id  = aws_efs_file_system.wp-eb-files.id
  subnet_id       = aws_subnet.wp-data-b.id
  security_groups = [aws_security_group.efs_file_system_wp-eb-files_group.id]
}
