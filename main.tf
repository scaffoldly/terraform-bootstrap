module "aws_organization" {
  source = "./aws-organization"
  name   = data.external.git.result.organization
}

module "api_gateway" {
  source = "./aws-api-gateway"

  providers = {
    aws = aws.org
  }
}

# TODO terraform 0.13 module loops
module "serverless-example-api" {
  source       = "./repository-serverless-api"
  service_name = "example"
}
