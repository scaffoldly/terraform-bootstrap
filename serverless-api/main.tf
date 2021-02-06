variable "service_name" {}
variable "stage_domains" {
  type = map(any)
}
variable "additional_env_vars" {
  type = map(any)
}

module "repository" {
  source = "./github-repository"

  template_repo = "serverless-template-api"
  prefix        = "serverless"
  suffix        = "api"

  # additional_env_vars = var.additional_env_vars

  service_name = var.service_name

  stage_domains = var.stage_domains
}

module "aws_iam" {
  source = "./aws-iam"

  repository_name = module.repository.name
}

module "stage" {
  source   = "./stage"
  for_each = var.stage_domains

  domain = lookup(each.value, "serverless_api_domain", "unknown-domain")

  name  = var.service_name
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
