resource "aws_iam_policy" "cloudfront_realtime_log_config_cdnLogConfig_st_wp-analytics" {
  name        = "cloudfront_realtime_log_config_cdnLogConfig_st_wp-analytics"
  description = "Access Policy for cdnLogConfig"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:DescribeStreamSummary",
        "kinesis:PutRecord",
        "kinesis:PutRecords"
      ],
      "Resource": [
        "${aws_kinesis_stream.cdnLogStream.arn}"
      ],
      "Sid": "AllowCdnToWriteLog"
    }
  ]
})
}

resource "aws_iam_policy" "kinesis_firehose_delivery_stream_cdnLogFirehose_st_wp-analytics" {
  name        = "kinesis_firehose_delivery_stream_cdnLogFirehose_st_wp-analytics"
  description = "Access Policy for cdnLogFirehose"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:DescribeStreamSummary",
        "kinesis:GetRecords",
        "kinesis:GetShardIterator",
        "kinesis:ListShards"
      ],
      "Resource": [
        "${aws_kinesis_stream.cdnLogStream.arn}"
      ],
      "Sid": "AllowFirehoseToReadLog"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads"
      ],
      "Resource": [
        "${aws_s3_bucket.cdnLogBucket.arn}"
      ],
      "Sid": "AllowBucketLevelActions"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.cdnLogBucket.arn}/*"
      ],
      "Sid": "AllowObjectDelivery"
    }
  ]
})
}

resource "aws_iam_policy" "lambda_function_analyticsPage_st_wp-analytics" {
  name        = "lambda_function_analyticsPage_st_wp-analytics"
  description = "Access Policy for analyticsPage"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "athena:GetQueryExecution",
        "athena:GetQueryResults",
        "athena:StartQueryExecution",
        "athena:StopQueryExecution"
      ],
      "Resource": [
        "${aws_athena_workgroup.cdnAnalytics.arn}"
      ],
      "Sid": "AllowRunQueriesInWorkgroup"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.analyticsPageLogs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:Scan"
      ],
      "Resource": [
        "${aws_dynamodb_table.cspTable.arn}"
      ],
      "Sid": "AllowCspTableScan"
    },
    {
      "Effect": "Allow",
      "Action": [
        "glue:GetTable"
      ],
      "Resource": [
        "${aws_glue_catalog_database.cdn_analytics.arn}",
        "${aws_glue_catalog_table.cdn_log.arn}",
        "arn:aws:glue:us-west-2:952133486861:catalog"
      ],
      "Sid": "AllowReadTable"
    },
    {
      "Effect": "Allow",
      "Action": [
        "glue:GetDatabase"
      ],
      "Resource": [
        "${aws_glue_catalog_database.cdn_analytics.arn}",
        "arn:aws:glue:us-west-2:952133486861:catalog"
      ],
      "Sid": "AllowReadDatabase"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": [
        "${aws_s3_bucket.cdnLogBucket.arn}"
      ],
      "Sid": "AllowBucketLevelActions"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetObject",
        "s3:ListMultipartUploadParts",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.cdnLogBucket.arn}/*.csv",
        "${aws_s3_bucket.cdnLogBucket.arn}/*.csv.metadata"
      ],
      "Sid": "AllowQueryResults"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.cdnLogBucket.arn}/cdn-log/*"
      ],
      "Sid": "AllowReadLog"
    },
    {
      "Effect": "Allow",
      "Action": [
        "xray:PutTelemetryRecords",
        "xray:PutTraceSegments"
      ],
      "Resource": [
        "*"
      ],
      "Sid": "AllowSendTracesToXRay"
    }
  ]
})
}

resource "aws_iam_policy" "lambda_function_cspReceiver_st_wp-analytics" {
  name        = "lambda_function_cspReceiver_st_wp-analytics"
  description = "Access Policy for cspReceiver"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.cspReceiverLogs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:UpdateItem"
      ],
      "Resource": [
        "${aws_dynamodb_table.cspTable.arn}"
      ],
      "Sid": "AllowCountReports"
    },
    {
      "Effect": "Allow",
      "Action": [
        "xray:PutTelemetryRecords",
        "xray:PutTraceSegments"
      ],
      "Resource": [
        "*"
      ],
      "Sid": "AllowSendTracesToXRay"
    }
  ]
})
}

resource "aws_iam_role" "analyticsPage_role" {
  name                  = "analyticsPage_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "analyticsPage_role"
    State          = "wp-analytics"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "cdnLogConfig_role" {
  name                  = "cdnLogConfig_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"cloudfront.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "cdnLogConfig_role"
    State          = "wp-analytics"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "cdnLogFirehose_role" {
  name                  = "cdnLogFirehose_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"firehose.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "cdnLogFirehose_role"
    State          = "wp-analytics"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "cspReceiver_role" {
  name                  = "cspReceiver_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "cspReceiver_role"
    State          = "wp-analytics"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "cloudfront_realtime_log_config_cdnLogConfig_st_wp-analytics_attach_cdnLogConfig_role" {
  policy_arn = aws_iam_policy.cloudfront_realtime_log_config_cdnLogConfig_st_wp-analytics.arn
  role       = aws_iam_role.cdnLogConfig_role.name
}

resource "aws_iam_role_policy_attachment" "kinesis_firehose_delivery_stream_cdnLogFirehose_st_wp-analytics_attach_cdnLogFirehose_role" {
  policy_arn = aws_iam_policy.kinesis_firehose_delivery_stream_cdnLogFirehose_st_wp-analytics.arn
  role       = aws_iam_role.cdnLogFirehose_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_analyticsPage_st_wp-analytics_attach_analyticsPage_role" {
  policy_arn = aws_iam_policy.lambda_function_analyticsPage_st_wp-analytics.arn
  role       = aws_iam_role.analyticsPage_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_cspReceiver_st_wp-analytics_attach_cspReceiver_role" {
  policy_arn = aws_iam_policy.lambda_function_cspReceiver_st_wp-analytics.arn
  role       = aws_iam_role.cspReceiver_role.name
}
