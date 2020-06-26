module "repository" {
  source = "../repository"

  template_repo = "serverless-template-api"
  prefix        = "serverless"
  suffix        = "api"

  service_name = var.service_name
}
