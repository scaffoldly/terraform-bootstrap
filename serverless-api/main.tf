variable "service_name" {}
variable "subdomain" {}
variable "stage_domains" {
  type = map
}

module "repository" {
  source = "./github-repository"

  template_repo = "serverless-template-api"
  prefix        = "serverless"
  suffix        = "api"

  service_name = var.service_name
}

module "aws_iam" {
  source = "./aws-iam"

  repository_name = module.repository.name
}

module "stage" {
  source   = "./stage"
  for_each = var.stage_domains

  domain    = lookup(each.value, "domain", "unknown-domain")
  subdomain = var.subdomain

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
