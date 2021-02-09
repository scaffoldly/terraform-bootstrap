terraform {
  required_version = ">= 0.13"
}

module "aws_organization" {
  source = "./aws-organization"
  name   = var.organization
  email  = var.root_email
}

module "aws_logging" {
  source = "./aws-logging"

  account_name = module.aws_organization.account_name

  providers = {
    aws = aws.org
  }

  depends_on = [
    module.aws_organization
  ]
}

module "dns" {
  source = "./dns"

  serverless_api_subdomain = var.serverless_api_subdomain
  stages                   = var.stages

  providers = {
    aws = aws.org
  }

  depends_on = [
    module.aws_logging
  ]
}

module "aws_api_gateway" {
  source = "./aws-api-gateway"

  stage_domains = module.dns.stage_domains

  providers = {
    aws = aws.org
  }

  depends_on = [
    module.dns
  ]
}

module "serverless_api" {
  source   = "./serverless-api"
  for_each = var.serverless_apis

  service_name  = each.key
  stage_domains = module.dns.stage_domains

  providers = {
    aws = aws.org
  }

  depends_on = [
    module.aws_api_gateway
  ]
}

module "public_website" {
  source   = "./public-website"
  for_each = var.public_websites

  account_name  = module.aws_organization.account_name
  name          = each.key
  stage_domains = module.dns.stage_domains

  providers = {
    aws = aws.org
  }

  depends_on = [
    module.dns,
    module.aws_logging
  ]
}

module "config_files" {
  source   = "./config-files"
  for_each = var.serverless_apis

  repository_name        = module.serverless_api[each.key].repository_name
  stage_domains          = module.dns.stage_domains
  shared_env_vars        = var.shared_env_vars
  serverless_api_configs = zipmap(keys(var.serverless_apis), [for i, z in module.serverless_api : z if z == "stage_configs"])
}
