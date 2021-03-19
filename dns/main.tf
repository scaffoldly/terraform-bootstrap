terraform {
  required_version = ">= 0.14"
  experiments      = [module_variable_optional_attrs]
}

provider "aws" {}

provider "aws" {
  alias = "dns"
}

provider "time" {
  alias = "old"
}

variable "dns_provider" {
  type = string
}
variable "serverless_api_subdomain" {
  type = string
}

variable "stages" {
  type = map(
    object({
      domain           = string
      subdomain_suffix = optional(string)
    })
  )
}

module "dns" {
  for_each = var.stages
  source   = "./stage-dns"

  dns_provider = var.dns_provider

  stage            = each.key
  domain           = each.value.domain
  subdomain        = var.serverless_api_subdomain
  subdomain_suffix = each.value.subdomain_suffix != null ? each.value.subdomain_suffix : ""

  providers = {
    aws     = aws
    aws.org = aws # TODO REMOVE
    aws.dns = aws.dns
    time    = time.old # TODO REMOVE
  }
}

output "stage_domains" {
  value = {
    for domain in module.dns :
    domain.stage => {
      domain                = domain.domain
      subdomain             = domain.subdomain
      subdomain_suffix      = domain.subdomain_suffix
      serverless_api_domain = domain.serverless_api_domain
      certificate_arn       = domain.certificate_arn
      dns_provider          = domain.dns_provider
    }
  }
}
