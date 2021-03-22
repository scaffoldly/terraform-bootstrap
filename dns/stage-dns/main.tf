terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  alias = "dns"
}

variable "dns_provider" {
  type = string
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

resource "aws_route53_zone" "zone" {
  name              = local.serverless_api_domain
  delegation_set_id = var.delegation_set_id
}

data "aws_route53_zone" "zone" {
  count = var.dns_provider == "aws" ? 1 : 0

  name = "${var.domain}."

  provider = aws.dns
}

resource "aws_acm_certificate" "certificate" {
  domain_name               = "*.${var.domain}"
  subject_alternative_names = [var.domain]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "time_sleep" "check_email_for_cert_validations" {
  create_duration = "300s"

  depends_on = [
    aws_acm_certificate.certificate
  ]
}

resource "aws_route53_record" "verification_record" {
  # TODO check if the dns_provider is aws, would have added count if not for this stupid for_each
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
  zone_id = data.aws_route53_zone.zone[0].zone_id

  provider = aws.dns
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
  value = aws_acm_certificate.certificate.arn
}

output "dns_provider" {
  value = var.dns_provider
}
