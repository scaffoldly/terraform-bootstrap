variable "domains" {
  type = list
}

resource "aws_route53_delegation_set" "main" {}

module "dns" {
  count  = length(var.domains)
  source = "../aws-dns"

  domain            = var.domains[count.index]
  delegation_set_id = aws_route53_delegation_set.main.id
}

output "nameservers" {
  value = "${aws_route53_delegation_set.main.name_servers}"
}
