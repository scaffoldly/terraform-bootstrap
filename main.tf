locals {
  serverless_apis = var.auth_service ? merge(var.serverless_apis, {
    auth = {
      template  = "scaffoldly/sly-auth-api-template"
      repo_name = "sly-auth-api"
    }
  }) : var.serverless_apis
}

module "aws_organization" {
  source = "./organization"
  name   = var.organization
  email  = var.root_email

  providers = {
    aws = aws.root
  }
}

module "aws_logging" {
  source = "./logging" # TODO Add main.tf in ./logging

  account_name = module.aws_organization.account_name

  depends_on = [
    module.aws_organization
  ]
}

# TODO test with xyz.com|dev AND subdomain_suffix
module "dns" {
  source = "./dns"

  serverless_api_subdomain = var.serverless_api_subdomain
  stages                   = var.stages
  dns_provider             = var.dns_provider

  providers = {
    aws.dns = aws.root
  }

  depends_on = [
    module.aws_logging
  ]
}

module "email" {
  source = "./email"

  root_email    = var.root_email
  stage_domains = module.dns.stage_domains

  providers = {
    aws.dns = aws.root
  }

  depends_on = [
    module.dns
  ]
}

module "aws_api_gateway" {
  source = "./api-gateway"

  stage_domains = module.dns.stage_domains

  providers = {
    aws.dns = aws.root
  }

  depends_on = [
    module.dns
  ]
}

module "serverless_api" {
  source   = "./serverless-api"
  for_each = local.serverless_apis

  name          = each.key
  stage_domains = module.dns.stage_domains

  template  = lookup(each.value, "template", "scaffoldly/sls-rest-api-template")
  repo_name = lookup(each.value, "repo_name", null)

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

  template  = lookup(each.value, "template", "scaffoldly/web-cdn-template")
  repo_name = lookup(each.value, "repo_name", null)

  providers = {
    aws.dns = aws.root
  }

  depends_on = [
    module.dns,
    module.aws_logging
  ]
}

module "github_config_files_serverless_apis" {
  source   = "./github-config-files"
  for_each = local.serverless_apis

  organization    = var.organization
  repository_name = module.serverless_api[each.key].repository_name
  stages          = keys(var.stages)
  stage_urls      = zipmap(values(module.serverless_api)[*].repository_name, values(module.serverless_api)[*].stage_urls)
  # stage_env_vars  = module.serverless_api[each.key].stage_env_vars
  shared_env_vars = var.shared_env_vars

  depends_on = [
    module.public_website,
    module.serverless_api
  ]
}

output "TEMP_nl_output" {
  value = module.serverless_api["nonlive"].stage_env_vars
}

module "github_config_files_public_websites" {
  source   = "./github-config-files"
  for_each = var.public_websites

  organization    = var.organization
  repository_name = module.public_website[each.key].repository_name
  stages          = keys(var.stages)
  stage_urls      = zipmap(values(module.serverless_api)[*].repository_name, values(module.serverless_api)[*].stage_urls)
  # stage_env_vars  = module.public_website[each.key].stage_env_vars
  shared_env_vars = var.shared_env_vars

  depends_on = [
    module.public_website,
    module.serverless_api
  ]
}
