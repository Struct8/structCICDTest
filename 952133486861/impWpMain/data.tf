data "aws_route53_zone" "wpZone" {
  name = "cloudman.pro"
}

data "aws_ec2_managed_prefix_list" "cloudfront_origin_facing_ipv6" {
  name = "com.amazonaws.global.ipv6.cloudfront.origin-facing"
}
