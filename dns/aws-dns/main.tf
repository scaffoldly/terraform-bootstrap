variable "stage" {}
variable "domain" {}
variable "subdomain" {}
variable "subdomain_suffix" {}
variable "delegation_set_id" {}

locals {
  serverless_api_domain = var.subdomain_suffix != "" ? "${var.subdomain}-${var.subdomain_suffix}.${var.domain}" : "${var.subdomain}.${var.domain}"
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

# Used to give user 
resource "time_sleep" "check_email_for_cert_validations" {
  create_duration = "300s"

  depends_on = [
    aws_acm_certificate.certificate
  ]
}

# resource "aws_route53_record" "verification_record" {
#   for_each = {
#     for dvo in aws_acm_certificate.apex.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   name    = each.value.name
#   records = [each.value.record]
#   ttl     = 60
#   type    = each.value.type
#   zone_id = aws_route53_zone.zone.zone_id
# }

output "zone_id" {
  value = aws_route53_zone.zone.zone_id
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
