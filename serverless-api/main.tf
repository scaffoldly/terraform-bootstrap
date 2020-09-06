variable "service_name" {}
variable "subdomain" {}
variable "stage_domains" {
  type = map
}

module "repository" {
  source = "./github-repository"

  template_repo = "serverless-template-api"
  prefix        = "serverless"
  suffix        = "api"

  service_name = var.service_name
}

module "stage" {
  source   = "./aws-api-gateway-stage"
  for_each = var.stage_domains

  domain    = lookup(each.value, "domain", "unknown-domain")
  subdomain = var.subdomain

  name  = var.service_name
  stage = each.key
}
