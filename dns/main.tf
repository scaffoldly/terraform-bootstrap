variable "domains" {
  type = map
}

resource "aws_route53_delegation_set" "main" {}

module "dns" {
  for_each = var.domains
  source   = "../aws-dns"

  stage             = each.key
  domain            = each.value
  delegation_set_id = aws_route53_delegation_set.main.id
}

output "nameservers" {
  value = aws_route53_delegation_set.main.name_servers
}

output "stages" {
  value = {
    for domain in module.dns :
    domain.stage => {
      domain         = domain.domain
      certifcate_arn = domain.wildcard_certificate_arn
    }
  }
}
