locals {
  cloudtrail_bucket_name = "${var.account_name}-logs-cloudtrail"
  cloudfront_bucket_name = "${var.account_name}-logs-cloudfront"
}
