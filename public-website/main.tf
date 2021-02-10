variable "account_name" {}
variable "name" {}
variable "stage_domains" {
  type = map(any)
}
variable "template" {
  default = ""
}

locals {
  repository_suffix = var.template != "" ? split("/", var.template)[1] : ""
}

module "cloudfront" {
  source   = "./aws-cloudfront"
  for_each = var.stage_domains

  account_name     = var.account_name
  name             = var.name
  stage            = each.key
  domain           = lookup(each.value, "domain", "unknown-domain")
  subdomain_suffix = lookup(each.value, "subdomain_suffix", "unknown-domain-suffix")
  certificate_arn  = lookup(each.value, "certificate_arn", "unknown-certificate-arn")
}

module "repository" {
  source = "../github-repository"
  count  = var.template != "" ? 1 : 0

  template = var.template
  suffix   = local.repository_suffix
  name     = var.name
}
