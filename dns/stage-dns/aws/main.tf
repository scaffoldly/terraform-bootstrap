terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  alias = "dns"
}

variable "primary_domain" {
  type = string
}

variable "additional_domains" {
  type    = list(string)
  default = []
}

data "aws_route53_zone" "zone" {
  name = "${var.domain}."

  provider = aws.dns
}

resource "aws_acm_certificate" "certificate" {
  domain_name               = var.primary_domain
  subject_alternative_names = var.additional_domains
  validation_method         = "DNS"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "verification_record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.zone.zone_id

  provider = aws.dns
}

output "certificate_arn" {
  value = aws_acm_certificate.certificate.arn
}

output "domain_id" {
  value = data.aws_route53_zone.zone.zone_id
}
