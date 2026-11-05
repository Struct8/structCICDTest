data "aws_cloudfront_cache_policy" "policy_cachingoptimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "policy_cachingdisabled" {
  name = "Managed-CachingDisabled"
}
