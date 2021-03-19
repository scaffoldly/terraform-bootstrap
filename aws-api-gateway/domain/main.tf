terraform {
  required_version = ">= 0.14"
}

variable "zone_id" {
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

# TODO Switch this to regular A-Record
resource "aws_route53_record" "api_record" {
  name    = aws_api_gateway_domain_name.domain.domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.domain.cloudfront_zone_id
  }
}
