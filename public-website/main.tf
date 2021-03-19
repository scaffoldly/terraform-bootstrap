terraform {
  required_version = ">= 0.14"
}

variable "account_name" {
  type = string
}
variable "name" {
  type = string
}
# TODO: Remove nameservers and zone_id with switch to simpledns
variable "stage_domains" {
  type = map(
    object({
      domain                = string
      subdomain             = string
      subdomain_suffix      = string
      serverless_api_domain = string
      zone_id               = string
      certificate_arn       = string
      nameservers           = string
    })
  )
}
variable "template" {
  type = string
}
variable "repo_name" {
  type    = string
  default = ""
}

locals {
  template_suffix          = split("/", var.template)[1]
  scrubbed_template_suffix = replace(local.template_suffix, "-template", "")
  repo_name                = var.repo_name != "" ? var.repo_name : "${var.name}-${local.scrubbed_template_suffix}"
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

module "aws_iam" {
  source   = "./aws-iam"
  for_each = module.cloudfront

  stage           = each.value.stage
  repository_name = module.repository.name
  bucket_name     = each.value.bucket_name
  distribution_id = each.value.distribution_id
}

output "repository_name" {
  value = module.repository.name
}

# TODO Instructions to add CNAME records to cloudfronts
