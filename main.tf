module "aws_organization" {
  source = "./aws-organization"
  name   = data.external.git.result.organization
}

module "dns" {
  source = "./dns"

  domains = {
    nonlive = local.nonlive.domain,
    live    = local.live.domain,
  }

  providers = {
    aws = aws.org
  }

  depends_on = [module.aws_organization]
}

output "foo" {
  value = module.dns.stage_domains
}

module "aws_api_gateway" {
  source = "./aws-api-gateway"

  stages        = ["nonlive", "live"]
  subdomain     = local.api_subdomain
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
  source   = "./repository-serverless-api"
  for_each = local.serverless_apis

  service_name = each.key
}
