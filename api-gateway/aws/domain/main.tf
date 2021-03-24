terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  alias = "dns"
}

variable "dns_provider" {
  type = string
}
variable "dns_domain_id" {
  type = string
}
variable "domain" {
  type = string
}
variable "certificate_arn" {
  type = string
}

resource "aws_api_gateway_domain_name" "domain" {
  security_policy = "TLS_1_2"
  certificate_arn = var.certificate_arn
  domain_name     = var.domain
}

resource "aws_route53_record" "api_record" {
  name    = aws_api_gateway_domain_name.domain.domain_name
  type    = "A"
  zone_id = var.dns_domain_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.domain.cloudfront_zone_id
  }
}

module "aws_cname_record" {
  count  = var.dns_provider == "aws" ? 1 : 0
  source = "../../../dns/cname-record/aws"

  dns_domain_id = var.dns_domain_id
  domain_name   = aws_api_gateway_domain_name.domain.domain_name
  target        = aws_api_gateway_domain_name.domain.cloudfront_domain_name

  providers = {
    aws.dns = aws.dns
  }
}
