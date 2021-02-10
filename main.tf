terraform {
  required_version = ">= 0.14"
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

  service_name    = each.key
  stage_domains   = module.dns.stage_domains
  shared_env_vars = var.shared_env_vars

  template = lookup(each.value, "template", "serverless-rest-api")

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

  template = lookup(each.value, "template", "")

  providers = {
    aws = aws.org
  }

  depends_on = [
    module.dns,
    module.aws_logging
  ]
}

module "serverless_api_configs" {
  source   = "./serverless-api-configs"
  for_each = var.serverless_apis

  service_name    = module.serverless_api[each.key].service_name
  repository_name = module.serverless_api[each.key].repository_name
  stage_configs   = zipmap(keys(module.serverless_api), values(module.serverless_api)[*].stage_config)
}
