data "aws_s3_bucket" "flowlogs-bucket" {
  bucket = "flowlogs-bucket-952133486861-us-west-2-an"
}

data "aws_security_group" "instance_traffic-gen-private_group" {
  filter {
    name   = "tag:Name"
    values = ["instance_traffic-gen-private_group"]
  }
}
