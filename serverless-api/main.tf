terraform {
  required_version = ">= 0.15"
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
      stage_env_vars        = map(string)
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

module "repository" {
  source = "../github-repository"

  template = var.template
  name     = local.repo_name
}

module "aws_iam" {
  source = "./iam"

  repository_name = module.repository.name
}

module "stage" {
  source   = "./stage"
  for_each = var.stage_domains

  domain         = lookup(each.value, "serverless_api_domain", "unknown-domain")
  stage_env_vars = lookup(each.value, "stage_env_vars", {})

  name  = var.name
  stage = each.key

  repository_name = module.repository.name
}

module "secrets" {
  source   = "./secrets"
  for_each = module.stage

  stage                         = each.key
  repository_name               = module.repository.name
  deployer_aws_access_key       = module.aws_iam.deployer_access_key
  deployer_aws_secret_key       = module.aws_iam.deployer_secret_key
  aws_rest_api_id               = each.value.api_id
  aws_rest_api_root_resource_id = each.value.root_resource_id
}

output "service_name" {
  value = var.name
}

output "repository_name" {
  value = module.repository.name
}

output "stage_urls" {
  value = {
    for stage in module.stage :
    stage.name => stage.url
  }
}

output "stage_env_vars" {
  value = {
    for stage in module.stage :
    stage.name => stage.stage_env_vars
  }
}
