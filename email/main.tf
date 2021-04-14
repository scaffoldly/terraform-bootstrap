terraform {
  required_version = ">= 0.14"
  experiments      = [module_variable_optional_attrs]
}

provider "aws" {
  alias = "dns"
}

variable "root_email" {
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

resource "aws_ses_receipt_rule_set" "primary" {
  rule_set_name = "primary-rules"
}

resource "aws_ses_active_receipt_rule_set" "primary" {
  rule_set_name = aws_ses_receipt_rule_set.primary.rule_set_name
}

module "stage" {
  source   = "./stage"
  for_each = var.stage_domains

  stage            = each.key
  root_email       = var.root_email
  domain           = lookup(each.value, "domain", "unknown-domain")
  subdomain_suffix = lookup(each.value, "subdomain_suffix", "unknown-subdomain-suffix")
  dns_provider     = lookup(each.value, "dns_provider", "unknown-dns-provider")
  dns_domain_id    = lookup(each.value, "dns_domain_id", "unknown-dns-domain-id")
  rule_set_name    = aws_ses_receipt_rule_set.primary.rule_set_name

  providers = {
    aws.dns = aws.dns
  }
}
