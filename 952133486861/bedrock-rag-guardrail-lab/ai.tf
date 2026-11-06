resource "aws_bedrock_guardrail" "lab-guardrail" {
  name                      = "lab-guardrail"
  blocked_input_messaging   = "Sorry, the model cannot answer this question."
  blocked_outputs_messaging = "Sorry, the model cannot answer this question."
  content_policy_config {
    filters_config {
      input_strength  = "HIGH"
      output_strength = "NONE"
      type            = "PROMPT_ATTACK"
    }
  }
  contextual_grounding_policy_config {
    filters_config {
      threshold = 0.75
      type      = "GROUNDING"
    }
    filters_config {
      threshold = 0.5
      type      = "RELEVANCE"
    }
  }
  sensitive_information_policy_config {
    pii_entities_config {
      action        = "ANONYMIZE"
      input_action  = "ANONYMIZE"
      output_action = "ANONYMIZE"
      type          = "EMAIL"
    }
  }
  tags = {
    Name           = "lab-guardrail"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_bedrock_inference_profile" "bedrock-rag-answer-model" {
  name = "bedrock-rag-answer-model"
  model_source {
    copy_from = "arn:aws:bedrock:us-west-2::foundation-model/amazon.nova-lite-v1:0"
  }
  tags = {
    Name           = "bedrock-rag-answer-model"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_bedrockagent_data_source" "bedrock-rag-documents" {
  knowledge_base_id    = aws_bedrockagent_knowledge_base.bedrock-kb-lab.id
  name                 = "bedrock-rag-documents"
  data_deletion_policy = "DELETE"
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.bedrock-documents.arn
    }
  }
}

resource "aws_bedrockagent_knowledge_base" "bedrock-kb-lab" {
  name     = "bedrock-kb-lab"
  role_arn = aws_iam_role.role_kb_bedrock-kb-lab.arn
  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:us-west-2::foundation-model/amazon.titan-embed-text-v2:0"
    }
  }
  storage_configuration {
    type = "S3_VECTORS"
    s3_vectors_configuration {
      index_arn = aws_s3vectors_index.bedrock-kb-index.index_arn
    }
  }
  tags = {
    Name           = "bedrock-kb-lab"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.bedrockagent_knowledge_base_bedrock-kb-lab_st_bedrock-rag-guardrail-lab_attach]
}
