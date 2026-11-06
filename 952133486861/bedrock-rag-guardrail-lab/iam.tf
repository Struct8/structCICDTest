data "aws_iam_policy_document" "bedrockagent_knowledge_base_bedrock-kb-lab_st_bedrock-rag-guardrail-lab_doc" {
  statement {
    sid       = "ListTheDocuments"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.bedrock-documents.arn]
  }
  statement {
    sid       = "ReadTheDocuments"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bedrock-documents.arn}/*"]
  }
  statement {
    sid       = "UseTheVectorIndex"
    effect    = "Allow"
    actions   = ["s3vectors:DeleteVectors", "s3vectors:GetIndex", "s3vectors:GetVectors", "s3vectors:PutVectors", "s3vectors:QueryVectors"]
    resources = [aws_s3vectors_index.bedrock-kb-index.index_arn]
  }
  statement {
    sid       = "InvokeTheEmbeddingModel"
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel"]
    resources = ["arn:aws:bedrock:${data.aws_region.current.region}::foundation-model/amazon.titan-embed-text-v2:0"]
  }
}

resource "aws_iam_policy" "bedrockagent_knowledge_base_bedrock-kb-lab_st_bedrock-rag-guardrail-lab" {
  name        = "bedrockagent_knowledge_base_bedrock-kb-lab_st_bedrock-rag-guardrail-lab"
  description = "Access Policy for bedrock-kb-lab"
  policy      = data.aws_iam_policy_document.bedrockagent_knowledge_base_bedrock-kb-lab_st_bedrock-rag-guardrail-lab_doc.json
}

data "aws_iam_policy_document" "lambda_function_bedrock-rag-handler_st_bedrock-rag-guardrail-lab_doc" {
  statement {
    sid       = "AllowApplyGuardrail"
    effect    = "Allow"
    actions   = ["bedrock:ApplyGuardrail"]
    resources = [aws_bedrock_guardrail.lab-guardrail.guardrail_arn]
  }
  statement {
    sid       = "AllowInvokeInferenceProfile"
    effect    = "Allow"
    actions   = ["bedrock:GetInferenceProfile", "bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
    resources = [aws_bedrock_inference_profile.bedrock-rag-answer-model.arn]
  }
  statement {
    sid       = "AllowKnowledgeBaseRetrieve"
    effect    = "Allow"
    actions   = ["bedrock:Retrieve"]
    resources = [aws_bedrockagent_knowledge_base.bedrock-kb-lab.arn]
  }
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.bedrock-rag-handler-logs.arn}:*"]
  }
  statement {
    sid       = "AllowRetrieveAndGenerate"
    effect    = "Allow"
    actions   = ["bedrock:RetrieveAndGenerate"]
    resources = ["*"]
  }
  statement {
    sid       = "AllowInferenceProfileModel"
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
    resources = ["arn:aws:bedrock:${data.aws_region.current.region}::foundation-model/amazon.nova-lite-v1:0"]
  }
  statement {
    sid       = "AllowDataSourceSync"
    effect    = "Allow"
    actions   = ["bedrock:GetIngestionJob", "bedrock:ListIngestionJobs", "bedrock:StartIngestionJob"]
    resources = ["arn:aws:bedrock:*:${data.aws_caller_identity.current.account_id}:knowledge-base/${aws_bedrockagent_data_source.bedrock-rag-documents.knowledge_base_id}"]
  }
}

resource "aws_iam_policy" "lambda_function_bedrock-rag-handler_st_bedrock-rag-guardrail-lab" {
  name        = "lambda_function_bedrock-rag-handler_st_bedrock-rag-guardrail-lab"
  description = "Access Policy for bedrock-rag-handler"
  policy      = data.aws_iam_policy_document.lambda_function_bedrock-rag-handler_st_bedrock-rag-guardrail-lab_doc.json
}

resource "aws_iam_role" "bedrock-rag-handler_role" {
  name = "bedrock-rag-handler_role"
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
    Name           = "bedrock-rag-handler_role"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_kb_bedrock-kb-lab" {
  name = "role_kb_bedrock-kb-lab"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock.amazonaws.com"
      },
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
        }
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "role_kb_bedrock-kb-lab"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "bedrockagent_knowledge_base_bedrock-kb-lab_st_bedrock-rag-guardrail-lab_attach" {
  policy_arn = aws_iam_policy.bedrockagent_knowledge_base_bedrock-kb-lab_st_bedrock-rag-guardrail-lab.arn
  role       = aws_iam_role.role_kb_bedrock-kb-lab.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_bedrock-rag-handler_st_bedrock-rag-guardrail-lab_attach" {
  policy_arn = aws_iam_policy.lambda_function_bedrock-rag-handler_st_bedrock-rag-guardrail-lab.arn
  role       = aws_iam_role.bedrock-rag-handler_role.name
}
