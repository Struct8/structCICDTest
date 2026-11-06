data "aws_iam_policy_document" "bedrockagentcore_gateway_agent-lab-gateway_st_bedrock-agent-lab_doc" {
  statement {
    sid       = "InvokeTheTargetFunction"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.agent-lab-orders-tool.arn]
  }
}

resource "aws_iam_policy" "bedrockagentcore_gateway_agent-lab-gateway_st_bedrock-agent-lab" {
  name        = "bedrockagentcore_gateway_agent-lab-gateway_st_bedrock-agent-lab"
  description = "Access Policy for agent-lab-gateway"
  policy      = data.aws_iam_policy_document.bedrockagentcore_gateway_agent-lab-gateway_st_bedrock-agent-lab_doc.json
}

data "aws_iam_policy_document" "bedrockagentcore_harness_agent_lab_orders_st_bedrock-agent-lab_doc" {
  statement {
    sid       = "AgentCoreGatewayAccess"
    effect    = "Allow"
    actions   = ["bedrock-agentcore:InvokeGateway"]
    resources = [aws_bedrockagentcore_gateway.agent-lab-gateway.gateway_arn]
  }
  statement {
    sid       = "AgentCoreMemory"
    effect    = "Allow"
    actions   = ["bedrock-agentcore:CreateEvent", "bedrock-agentcore:DeleteEvent", "bedrock-agentcore:GetEvent", "bedrock-agentcore:ListEvents", "bedrock-agentcore:RetrieveMemoryRecords"]
    resources = [aws_bedrockagentcore_memory.agent_lab_memory.arn]
  }
  statement {
    sid       = "AgentCoreMemoryKey"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey", "kms:GenerateDataKey"]
    resources = [aws_kms_key.agent-lab-key.arn]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["bedrock-agentcore.${data.aws_region.current.region}.amazonaws.com"]
    }
  }
  statement {
    sid       = "CloudWatchMetricsPublish"
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["bedrock-agentcore"]
    }
  }
  statement {
    sid       = "EcrPublicTokenAccess"
    effect    = "Allow"
    actions   = ["ecr-public:GetAuthorizationToken", "logs:PutResourcePolicy", "sts:GetServiceBearerToken", "xray:GetSamplingRules", "xray:GetSamplingTargets", "xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
  statement {
    sid       = "AgentCoreWorkloadIdentity"
    effect    = "Allow"
    actions   = ["bedrock-agentcore:GetWorkloadAccessToken", "bedrock-agentcore:GetWorkloadAccessTokenForJWT"]
    resources = ["arn:aws:bedrock-agentcore:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:workload-identity-directory/default", "arn:aws:bedrock-agentcore:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:workload-identity-directory/default/workload-identity/harness_agent_lab_orders-*"]
  }
  statement {
    sid       = "BedrockModelInvocation"
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
    resources = ["arn:aws:bedrock:${data.aws_region.current.region}::foundation-model/amazon.nova-lite-v1:0"]
  }
  statement {
    sid       = "CloudWatchLogsDescribeGroups"
    effect    = "Allow"
    actions   = ["logs:DescribeLogGroups"]
    resources = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:*"]
  }
  statement {
    sid       = "CloudWatchLogsGroup"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:DescribeLogStreams"]
    resources = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/bedrock-agentcore/runtimes/*"]
  }
  statement {
    sid       = "CloudWatchLogsStream"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/bedrock-agentcore/runtimes/*:log-stream:*"]
  }
}

resource "aws_iam_policy" "bedrockagentcore_harness_agent_lab_orders_st_bedrock-agent-lab" {
  name        = "bedrockagentcore_harness_agent_lab_orders_st_bedrock-agent-lab"
  description = "Access Policy for agent_lab_orders"
  policy      = data.aws_iam_policy_document.bedrockagentcore_harness_agent_lab_orders_st_bedrock-agent-lab_doc.json
}

data "aws_iam_policy_document" "lambda_function_agent-lab-chat_st_bedrock-agent-lab_doc" {
  statement {
    sid       = "AllowApplyGuardrail"
    effect    = "Allow"
    actions   = ["bedrock:ApplyGuardrail"]
    resources = [aws_bedrock_guardrail.agent-lab-guardrail.guardrail_arn]
  }
  statement {
    sid       = "AllowInvokeHarness"
    effect    = "Allow"
    actions   = ["bedrock-agentcore:InvokeAgentRuntime", "bedrock-agentcore:InvokeHarness"]
    resources = [aws_bedrockagentcore_harness.agent_lab_orders.arn]
  }
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.agent-lab-chat-logs.arn}:*"]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_agent-lab-chat_st_bedrock-agent-lab" {
  name        = "lambda_function_agent-lab-chat_st_bedrock-agent-lab"
  description = "Access Policy for agent-lab-chat"
  policy      = data.aws_iam_policy_document.lambda_function_agent-lab-chat_st_bedrock-agent-lab_doc.json
}

data "aws_iam_policy_document" "lambda_function_agent-lab-orders-tool_st_bedrock-agent-lab_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.agent-lab-orders-tool-logs.arn}:*"]
  }
  statement {
    sid       = "ReadOrders"
    effect    = "Allow"
    actions   = ["dynamodb:GetItem"]
    resources = [aws_dynamodb_table.agent-lab-orders.arn]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_agent-lab-orders-tool_st_bedrock-agent-lab" {
  name        = "lambda_function_agent-lab-orders-tool_st_bedrock-agent-lab"
  description = "Access Policy for agent-lab-orders-tool"
  policy      = data.aws_iam_policy_document.lambda_function_agent-lab-orders-tool_st_bedrock-agent-lab_doc.json
}

resource "aws_iam_role" "agent-lab-chat_role" {
  name = "agent-lab-chat_role"
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
}

resource "aws_iam_role" "agent-lab-orders-tool_role" {
  name = "agent-lab-orders-tool_role"
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
    Name           = "agent-lab-orders-tool_role"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_agent-lab-gateway" {
  name = "role_agent-lab-gateway"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock-agentcore.amazonaws.com"
      },
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:bedrock-agentcore:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:gateway/*"
        }
      }
    }
  ]
})
  tags = {
    Name           = "role_agent-lab-gateway"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_agent_lab_orders" {
  name = "role_agent_lab_orders"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock-agentcore.amazonaws.com"
      },
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:bedrock-agentcore:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"
        }
      }
    }
  ]
})
  tags = {
    Name           = "role_agent_lab_orders"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "bedrockagentcore_gateway_agent-lab-gateway_st_bedrock-agent-lab_attach" {
  policy_arn = aws_iam_policy.bedrockagentcore_gateway_agent-lab-gateway_st_bedrock-agent-lab.arn
  role       = aws_iam_role.role_agent-lab-gateway.name
}

resource "aws_iam_role_policy_attachment" "bedrockagentcore_harness_agent_lab_orders_st_bedrock-agent-lab_attach" {
  policy_arn = aws_iam_policy.bedrockagentcore_harness_agent_lab_orders_st_bedrock-agent-lab.arn
  role       = aws_iam_role.role_agent_lab_orders.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_agent-lab-chat_st_bedrock-agent-lab_attach" {
  policy_arn = aws_iam_policy.lambda_function_agent-lab-chat_st_bedrock-agent-lab.arn
  role       = aws_iam_role.agent-lab-chat_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_agent-lab-orders-tool_st_bedrock-agent-lab_attach" {
  policy_arn = aws_iam_policy.lambda_function_agent-lab-orders-tool_st_bedrock-agent-lab.arn
  role       = aws_iam_role.agent-lab-orders-tool_role.name
}

resource "aws_kms_key" "agent-lab-key" {
  bypass_policy_lockout_safety_check = false
  customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  deletion_window_in_days            = 7
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
    Name           = "agent-lab-key"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
}
