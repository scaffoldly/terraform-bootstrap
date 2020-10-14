variable "stages" {
  type = map
}

resource "aws_route53_delegation_set" "main" {}

module "dns" {
  for_each = var.stages
  source   = "../aws-dns"

  stage             = each.key
  subdomain         = each.value.serverless_api_subdomain
  domain            = each.value.domain
  delegation_set_id = aws_route53_delegation_set.main.id
}

output "nameservers" {
  value = aws_route53_delegation_set.main.name_servers
}

output "stage_domains" {
  value = {
    for domain in module.dns :
    domain.stage => {
      domain          = domain.domain
      zone_id         = domain.zone_id
      certificate_arn = domain.certificate_arn
    }
  }
}
