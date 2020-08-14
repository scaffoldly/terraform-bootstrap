module "aws_organization" {
  source = "./aws-organization"
  name   = data.external.git.result.organization
}

module "api_gateway" { # TODO Rename to aws_api_gateway
  source = "./aws-api-gateway"

  providers = {
    aws = aws.org
  }

  depends_on = [module.aws_organization]
}

module "aws_logs" {
  source = "./aws-logs"

  account_name = module.aws_organization.account_name

  providers = {
    aws = aws.org
  }

  depends_on = [module.aws_organization]
}


# TODO terraform 0.13 module loops
module "serverless-example-api" {
  source       = "./repository-serverless-api"
  service_name = "example"
}
