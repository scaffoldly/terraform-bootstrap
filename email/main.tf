terraform {
  required_version = ">= 0.15"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.dns]
    }
  }
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
      platform_domains      = map(string)
      certificate_arn       = string
      dns_provider          = string
      dns_domain_id         = string
      stage_env_vars        = map(string)
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

  stage         = each.key
  root_email    = var.root_email
  mail_domain   = each.value.platform_domains.mail_domain
  dns_provider  = lookup(each.value, "dns_provider", "unknown-dns-provider") # TODO: Remove lookup(...) usage
  dns_domain_id = lookup(each.value, "dns_domain_id", "unknown-dns-domain-id")
  rule_set_name = aws_ses_receipt_rule_set.primary.rule_set_name

  providers = {
    aws.dns = aws.dns
  }
}
