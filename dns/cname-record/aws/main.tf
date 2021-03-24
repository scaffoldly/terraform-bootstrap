terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  alias = "dns"
}

variable "dns_domain_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "target" {
  type = string
}

resource "aws_route53_record" "record" {
  name    = var.domain_name
  type    = "CNAME"
  zone_id = var.dns_domain_id
  ttl     = "300"

  records = [var.target]

  provider = aws.dns
}
