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

  service_name  = each.key
  stage_domains = module.dns.stage_domains

  template  = lookup(each.value, "template", "scaffoldly/serverless-rest-api")
  repo_name = lookup(each.value, "repo_name", "")

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

  template  = lookup(each.value, "template", "scaffoldly/web-angular")
  repo_name = lookup(each.value, "repo_name", "")

  providers = {
    aws = aws.org
  }

  depends_on = [
    module.dns,
    module.aws_logging
  ]
}

module "github_config_files_serverless_apis" {
  source   = "./github-config-files"
  for_each = var.serverless_apis

  repository_name = module.serverless_api[each.key].repository_name
  stages          = keys(var.stages)
  stage_urls      = zipmap(values(module.serverless_api)[*].repository_name, values(module.serverless_api)[*].stage_urls)
  shared_env_vars = var.shared_env_vars

  depends_on = [
    module.public_website,
    module.serverless_api
  ]
}

module "github_config_files_public_websites" {
  source   = "./github-config-files"
  for_each = var.public_websites

  repository_name = module.public_website[each.key].repository_name
  stages          = keys(var.stages)
  stage_urls      = zipmap(values(module.serverless_api)[*].repository_name, values(module.serverless_api)[*].stage_urls)
  shared_env_vars = var.shared_env_vars

  depends_on = [
    module.public_website,
    module.serverless_api
  ]
}
