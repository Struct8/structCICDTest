resource "aws_cloudwatch_log_resource_policy" "transaction-search-us-west-2_spans" {
  policy_name = "transaction-search-us-west-2-xray-spans"
  policy_document = jsonencode({
  Version = "2012-10-17"
  Statement = [{
    Sid       = "TransactionSearchXRayAccess"
    Effect    = "Allow"
    Principal = { Service = "xray.amazonaws.com" }
    Action    = "logs:PutLogEvents"
    Resource = [
      "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:aws/spans:*",
      "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/application-signals/data:*"
    ]
    Condition = {
      ArnLike      = { "aws:SourceArn" = "arn:aws:xray:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*" }
      StringEquals = { "aws:SourceAccount" = "${data.aws_caller_identity.current.account_id}" }
    }
  }]
})
}

resource "aws_xray_indexing_rule" "transaction-search-us-west-2_indexing" {
  name = "Default"
  rule {
    probabilistic {
      desired_sampling_percentage = 100
    }
  }
  depends_on = [aws_xray_trace_segment_destination.transaction-search-us-west-2]
}

resource "aws_xray_trace_segment_destination" "transaction-search-us-west-2" {
  destination = "CloudWatchLogs"
  depends_on  = [aws_cloudwatch_log_resource_policy.transaction-search-us-west-2_spans]
}
