variable "account_name" {}
variable "name" {}
variable "stage_domains" {
  type = map(any)
}
variable "template" {}
variable "repo_name" {
  default = ""
}

locals {
  repo_name = var.repo_name != "" ? var.repo_name : "${var.name}-${split("/", var.template)[1]}"
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

  template = var.template
  name     = local.repo_name
}

output "repository_name" {
  value = module.repository.name
}
