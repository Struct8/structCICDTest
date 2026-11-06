resource "aws_s3_bucket" "bedrock-documents" {
  bucket              = "bedrock-documents-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
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
    bucket_key_enabled = true
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

resource "aws_s3_object" "bedrock-rag-documents-files" {
  for_each     = fileset("${path.module}/.external_modules/struct8-templates/templates/bedrock-rag-lab/v1/documents", "**")
  source       = "${path.module}/.external_modules/struct8-templates/templates/bedrock-rag-lab/v1/documents/${each.value}"
  bucket       = aws_s3_bucket.bedrock-documents.bucket
  content_type = lookup({ "md" = "text/markdown; charset=utf-8" }, lower(regex("[^.]*$", each.value)), "application/octet-stream")
  etag         = filemd5("${path.module}/.external_modules/struct8-templates/templates/bedrock-rag-lab/v1/documents/${each.value}")
  key          = each.value
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
  metadata_configuration {
    non_filterable_metadata_keys = ["AMAZON_BEDROCK_TEXT", "AMAZON_BEDROCK_METADATA"]
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
  tags = {
    Name           = "bedrock-vectors"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
}
