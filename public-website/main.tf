terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  alias = "dns"
}

provider "github" {
  alias = "org"
}

variable "organization" {
  type = string
}
variable "account_name" {
  type = string
}
variable "name" {
  type = string
}
variable "stage_domains" {
  type = map(
    object({
      domain                = string
      subdomain             = string
      subdomain_suffix      = string
      serverless_api_domain = string
      certificate_arn       = string
      dns_provider          = string
      dns_domain_id         = string
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
  repo_name                = var.repo_name != null ? var.repo_name : "${var.name}-${local.scrubbed_template_suffix}"
}

module "cloudfront" {
  source   = "./distribution"
  for_each = var.stage_domains

  account_name     = var.account_name
  name             = var.name
  stage            = each.key
  dns_provider     = lookup(each.value, "dns_provider", "unknown-dns-provider")
  dns_domain_id    = lookup(each.value, "dns_domain_id", "unknown-dns-domain-id")
  domain           = lookup(each.value, "domain", "unknown-domain")
  subdomain_suffix = lookup(each.value, "subdomain_suffix", "unknown-domain-suffix")
  certificate_arn  = lookup(each.value, "certificate_arn", "unknown-certificate-arn")

  providers = {
    aws.dns = aws.dns
  }
}

module "repository" {
  source = "../github-repository"

  template = var.template
  name     = local.repo_name

  providers = {
    github.org = github.org
  }
}

module "aws_iam" {
  source   = "./iam"
  for_each = module.cloudfront

  stage           = each.value.stage
  organization    = var.organization
  repository_name = module.repository.name
  bucket_name     = each.value.bucket_name
  distribution_id = each.value.distribution_id

  providers = {
    github.org = github.org
  }
}

output "repository_name" {
  value = module.repository.name
}

