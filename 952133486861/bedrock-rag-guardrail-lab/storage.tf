resource "aws_s3_bucket" "bedrock-documents" {
  bucket              = "bedrock-documents-952133486861-us-west-2-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "bedrock-documents"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_ownership_controls" "bedrock-documents_controls" {
  bucket = aws_s3_bucket.bedrock-documents.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "bedrock-documents_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.bedrock-documents.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bedrock-documents_configuration" {
  bucket = aws_s3_bucket.bedrock-documents.id
  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "bedrock-documents_versioning" {
  bucket = aws_s3_bucket.bedrock-documents.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}

resource "aws_s3_object" "bedrock-rag-documents-files_returns-and-refunds_md" {
  bucket       = aws_s3_bucket.bedrock-documents.bucket
  content_type = "text/markdown; charset=utf-8"
  key          = "returns-and-refunds.md"
  tags = {
    Name           = "bedrock-rag-documents-files"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "bedrock-rag-documents-files_shipping-policy_md" {
  bucket       = aws_s3_bucket.bedrock-documents.bucket
  content_type = "text/markdown; charset=utf-8"
  key          = "shipping-policy.md"
  tags = {
    Name           = "bedrock-rag-documents-files"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "bedrock-rag-documents-files_subscriptions_md" {
  bucket       = aws_s3_bucket.bedrock-documents.bucket
  content_type = "text/markdown; charset=utf-8"
  key          = "subscriptions.md"
  tags = {
    Name           = "bedrock-rag-documents-files"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3vectors_index" "bedrock-kb-index" {
  index_name         = "bedrock-kb-index"
  vector_bucket_name = aws_s3vectors_vector_bucket.bedrock-vectors.vector_bucket_name
  data_type          = "float32"
  dimension          = 1024
  distance_metric    = "cosine"
  encryption_configuration {
    sse_type = "AES256"
  }
  metadata_configuration {
    non_filterable_metadata_keys = ["AMAZON_BEDROCK_METADATA", "AMAZON_BEDROCK_TEXT"]
  }
  tags = {
    Name           = "bedrock-kb-index"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3vectors_vector_bucket" "bedrock-vectors" {
  vector_bucket_name = "bedrock-vectors"
  force_destroy      = false
  encryption_configuration {
    sse_type = "AES256"
  }
  lifecycle {
    ignore_changes = [force_destroy]
  }
  tags = {
    Name           = "bedrock-vectors"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
}
