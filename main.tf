module "aws_organization" {
  source = "./aws-organization"
  name   = data.external.git.result.organization
}

module "dns" {
  source = "./dns"

  domains = [
    local.nonlive.domain,
    local.live.domain,
  ]

  providers = {
    aws = aws.org
  }

  depends_on = [module.aws_organization]
}

module "api_gateway" { # TODO Rename to aws_api_gateway
  source = "./aws-api-gateway"

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
