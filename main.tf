terraform {
  required_version = ">= 0.13"
}

module "aws_organization" {
  source = "./aws-organization"
  name   = var.organization
  email  = var.root_email
}

module "dns" {
  source = "./dns"

  domains = {
    nonlive = var.stages["nonlive"]
    live    = var.stages["live"]
  }

  providers = {
    aws = aws.org
  }

  depends_on = [module.aws_organization]
}

module "aws_api_gateway" {
  source = "./aws-api-gateway"

  stages        = var.stages
  subdomain     = var.api_subdomain
  stage_domains = module.dns.stage_domains

  providers = {
    aws = aws.org
  }

  depends_on = [module.aws_organization]
}

module "aws_logging" {
  source = "./aws-logging"

  account_name = module.aws_organization.account_name

  providers = {
    aws = aws.org
  }

  depends_on = [module.aws_organization]
}

module "serverless_api" {
  source   = "./serverless-api"
  for_each = var.serverless_apis

  service_name = each.key

  subdomain     = var.api_subdomain
  stage_domains = module.dns.stage_domains

  providers = {
    aws = aws.org
  }

  depends_on = [module.aws_organization]
}
