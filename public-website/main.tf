variable "account_name" {}

variable "name" {}
variable "stages" {
  type = map
}

variable "stage_domains" {
  type = map
}

module "cloudfront" {
  source   = "./aws-cloudfront"
  for_each = var.stages

  account_name = var.account_name

  name      = var.name
  stage     = each.key
  subdomain = lookup(each.value, "subdomain", "")

  stage_domain = lookup(var.stage_domains, each.key, {})
}
