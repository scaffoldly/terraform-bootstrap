# TODO terraform 0.13 module loops
module "aws_organization" {
  source = "./aws-organization"
  name   = data.external.git.result.organization
}

# TODO terraform 0.13 module loops
module "serverless-example-api" {
  source       = "./repository-serverless-api"
  service_name = "example"
}
