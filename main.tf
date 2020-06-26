# TODO terraform 0.13 module loops
module "serverless-example-api" {
  source       = "./repository-serverless-api"
  service_name = "example"
}
