variable "domain" {}
variable "delegation_set_id" {}

resource "aws_route53_zone" "zone" {
  name              = var.domain
  delegation_set_id = var.delegation_set_id
}

resource "aws_acm_certificate" "apex_wildcard" {
  domain_name       = var.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "apex_wildcard_validation" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = aws_acm_certificate.apex_wildcard.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.apex_wildcard.domain_validation_options.0.resource_record_type
  ttl     = "60"
  records = [aws_acm_certificate.apex_wildcard.domain_validation_options.0.resource_record_value]
}

resource "aws_acm_certificate" "subdomain_wildcard" {
  domain_name       = "*.${var.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "subdomain_wildcard_validation" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = aws_acm_certificate.subdomain_wildcard.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.subdomain_wildcard.domain_validation_options.0.resource_record_type
  ttl     = "60"
  records = [aws_acm_certificate.subdomain_wildcard.domain_validation_options.0.resource_record_value]
}
