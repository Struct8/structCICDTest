data "aws_s3_bucket" "flowlogs-bucket" {
  bucket = "flowlogs-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
}
