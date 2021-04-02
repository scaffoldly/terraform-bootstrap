terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  alias = "dns"
}

variable "dns_provider" {
  type    = string
  default = "aws"
}
variable "stage" {
  type = string
}
variable "domain" {
  type = string
}
variable "subdomain" {
  type = string
}
variable "subdomain_suffix" {
  type = string
}
variable "delegation_set_id" { # TODO Remove
  type = string
}

locals {
  serverless_api_domain = var.subdomain_suffix != "" ? "${var.subdomain}-${var.subdomain_suffix}.${var.domain}" : "${var.subdomain}.${var.domain}"
}

data "aws_route53_zone" "zone" {
  name = "${var.domain}."

  provider = aws.dns
}

# TODO: Different Certs for CloudFront vs API Gateway
resource "aws_acm_certificate" "serverless_api_domain" {
  domain_name               = local.serverless_api_domain
  subject_alternative_names = [var.domain, "*.${var.domain}"]
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
    for dvo in aws_acm_certificate.serverless_api_domain.domain_validation_options : dvo.domain_name => {
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

  allow_overwrite = true # Dirty hack to allow wildcard certs to not collide

  provider = aws.dns
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.serverless_api_domain.arn
  validation_record_fqdns = values(aws_route53_record.verification_record)[*].fqdn
}

output "domain" {
  value = var.domain
}

output "subdomain" {
  value = var.subdomain
}

output "subdomain_suffix" {
  value = var.subdomain_suffix
}

output "serverless_api_domain" {
  value = local.serverless_api_domain
}

output "stage" {
  value = var.stage
}

output "certificate_arn" {
  value = aws_acm_certificate.serverless_api_domain.arn
}

output "dns_provider" {
  value = var.dns_provider
}

output "dns_domain_id" {
  value = data.aws_route53_zone.zone.zone_id
}
