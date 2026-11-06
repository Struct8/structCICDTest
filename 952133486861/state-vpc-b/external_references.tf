data "aws_s3_bucket" "flowlogs-bucket" {
  bucket = "flowlogs-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
}

data "aws_security_group" "instance_traffic-gen-private_group" {
  filter {
    name   = "tag:Name"
    values = ["instance_traffic-gen-private_group"]
  }
}
