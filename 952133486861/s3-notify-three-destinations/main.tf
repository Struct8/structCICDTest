terraform {
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/s3-notify-three-destinations/main.tfstate"
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

data "aws_iam_policy_document" "lambda_function_processor_st_s3-notify-three-destinations_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.processor-logs.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_processor_st_s3-notify-three-destinations" {
  name        = "lambda_function_processor_st_s3-notify-three-destinations"
  description = "Access Policy for processor"
  policy      = data.aws_iam_policy_document.lambda_function_processor_st_s3-notify-three-destinations_doc.json
}

resource "aws_iam_role" "processor_role" {
  name = "processor_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "processor_role"
    State          = "s3-notify-three-destinations"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_processor_st_s3-notify-three-destinations_attach" {
  policy_arn = aws_iam_policy.lambda_function_processor_st_s3-notify-three-destinations.arn
  role       = aws_iam_role.processor_role.name
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "source" {
  bucket              = "s3-notify-three-destinations-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "source"
    State          = "s3-notify-three-destinations"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_notification" "source-events" {
  bucket      = aws_s3_bucket.source.id
  eventbridge = true
  lambda_function {
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    filter_suffix       = ".csv"
    lambda_function_arn = aws_lambda_function.processor.arn
  }
  queue {
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".jpg"
    queue_arn     = aws_sqs_queue.archive.arn
  }
  topic {
    events    = ["s3:ObjectRemoved:*"]
    topic_arn = aws_sns_topic.alerts.arn
  }
  depends_on = [aws_lambda_permission.perm_aws_s3_bucket_source_to_processor, aws_sns_topic_policy.aws_sns_topic_policy_alerts_st_s3-notify-three-destinations, aws_sqs_queue_policy.aws_sqs_queue_policy_archive_st_s3-notify-three-destinations]
}

resource "aws_s3_bucket_ownership_controls" "source_controls" {
  bucket = aws_s3_bucket.source.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "source_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.source.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "source_configuration" {
  bucket = aws_s3_bucket.source.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "source_versioning" {
  bucket = aws_s3_bucket.source.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_struct8-hub_processor" {
  output_path = "${path.module}/struct8-hub_processor.zip"
  source_dir  = "${path.module}/.external_modules/struct8-hub/prebuilt"
  type        = "zip"
}

resource "aws_lambda_function" "processor" {
  function_name                  = "processor"
  architectures                  = ["arm64"]
  description                    = "Runs on every .csv uploaded under 'uploads/'. Code is the prebuilt Hub artifact from the connected GitHub node (Struct8/struct8-hub, folder 'prebuilt', handler index.handler). Writes to the connected CloudWatch log group, where you confirm it ran."
  filename                       = data.archive_file.archive_struct8-hub_processor.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.processor_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-hub_processor.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
    NAME    = "processor"
    REGION  = data.aws_region.current.region
    ACCOUNT = data.aws_caller_identity.current.account_id
  }
  }
  tags = {
    Name           = "processor"
    State          = "s3-notify-three-destinations"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_processor_st_s3-notify-three-destinations_attach]
}

resource "aws_lambda_permission" "perm_aws_s3_bucket_source_to_processor" {
  function_name       = aws_lambda_function.processor.function_name
  principal           = "s3.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = aws_s3_bucket.source.arn
  statement_id_prefix = "perm_aws_s3_bucket_source_to_processor"
}




### CATEGORY: INTEGRATION ###

resource "aws_sqs_queue" "archive" {
  name                              = "archive"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 60
  tags = {
    Name           = "archive"
    State          = "s3-notify-three-destinations"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_sqs_queue_policy_archive_st_s3-notify-three-destinations_doc" {
  statement {
    sid    = "AllowS3SendMessage"
    effect = "Allow"
    principals {
      identifiers = ["s3.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.archive.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_archive_st_s3-notify-three-destinations" {
  policy    = data.aws_iam_policy_document.aws_sqs_queue_policy_archive_st_s3-notify-three-destinations_doc.json
  queue_url = aws_sqs_queue.archive.id
}

resource "aws_sns_topic" "alerts" {
  name = "alerts"
  tags = {
    Name           = "alerts"
    State          = "s3-notify-three-destinations"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_sns_topic_policy_alerts_st_s3-notify-three-destinations_doc" {
  statement {
    sid    = "AllowS3Publish"
    effect = "Allow"
    principals {
      identifiers = ["s3.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alerts.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sns_topic_policy" "aws_sns_topic_policy_alerts_st_s3-notify-three-destinations" {
  arn    = aws_sns_topic.alerts.arn
  policy = data.aws_iam_policy_document.aws_sns_topic_policy_alerts_st_s3-notify-three-destinations_doc.json
}

resource "aws_sns_topic_subscription" "email-alert" {
  endpoint  = "lab@example.com"
  protocol  = "email"
  topic_arn = aws_sns_topic.alerts.arn
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "processor-logs" {
  name              = "/aws/lambda/processor"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  skip_destroy      = false
  tags = {
    Name           = "processor-logs"
    State          = "s3-notify-three-destinations"
    Struct8Creator = "rmay struct"
  }
}


