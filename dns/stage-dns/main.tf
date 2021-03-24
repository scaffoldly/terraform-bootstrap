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

module "aws_dns" {
  # Prep of DNS provider option
  count = var.dns_provider == "aws" ? 1 : 0

  source = "./aws"

  domain = var.domain

  providers = {
    aws.dns = aws.dns
  }
}

resource "aws_route53_zone" "zone" {
  name              = local.serverless_api_domain
  delegation_set_id = var.delegation_set_id
}

resource "aws_acm_certificate" "certificate" {
  domain_name               = "*.${var.domain}"
  subject_alternative_names = [var.domain]
  validation_method         = "EMAIL"

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
  value = module.aws_dns[0].certificate_arn
}

output "dns_provider" {
  value = var.dns_provider
}

output "dns_domain_id" {
  value = module.aws_dns[0].certificate_arn
}
