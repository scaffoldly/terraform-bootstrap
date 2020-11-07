variable "account_name" {}
variable "name" {}
variable "stage_domains" {
  type = map
}

module "cloudfront" {
  source   = "./aws-cloudfront"
  for_each = var.stage_domains

  account_name = var.account_name

  name             = var.name
  stage            = each.key
  domain           = lookup(each.value, "domain", "unknown-domain")
  subdomain_prefix = lookup(each.value, "subdomain_prefix", "unknown-prefix")
  certificate_arn  = lookup(each.value, "certificate_arn", "unknown-certificate-arn")

  stage_domain = each.value
}
