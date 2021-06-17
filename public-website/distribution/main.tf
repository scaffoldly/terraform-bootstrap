terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.dns]
    }
  }
}

variable "account_name" {
  type = string
}
variable "name" {
  type = string
}
variable "stage" {
  type = string
}
variable "stage_env_vars" {
  type    = map(string)
  default = {}
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
variable "subdomain_suffix" {
  type = string
}
variable "certificate_arn" {
  type = string
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_route53_zone" "zone" {
  name = "${var.domain}."

  provider = aws.dns
}

data "aws_s3_bucket" "logs_bucket" {
  bucket = "${var.account_name}-logs-cloudfront"
}

locals {
  domain = var.subdomain_suffix != "" ? "${var.name}-${var.subdomain_suffix}.${var.domain}" : "${var.name}.${var.domain}"
}

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "${var.account_name}-${var.name}-${var.stage}"
  acl           = "private"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = data.aws_s3_bucket.logs_bucket.id
    target_prefix = "${local.domain}/s3/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "identity" {}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    # This statement defers access control evaluation to IAM Policiesfor any 
    # IAM role or user in this AWS account, making ACL control within the 
    # account more succinct, instead of having to navigate through IAM policies
    # and S3 bucket policies
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.bucket.id}",
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.bucket.id}/*",
    ]
  }

  statement {
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.identity.iam_arn
      ]
    }

    actions = [
      "s3:Get*",
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.bucket.id}",
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.bucket.id}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  depends_on = [
    aws_s3_bucket_public_access_block.block,
  ]
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    origin_id   = aws_s3_bucket.bucket.id
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.identity.cloudfront_access_identity_path
    }
  }

  default_root_object = "index.html"

  custom_error_response { # TODO Make sure Angular works with this
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response { # TODO Make sure Angular works with this
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }

  default_cache_behavior {
    min_ttl     = 0
    default_ttl = 600
    max_ttl     = 86400

    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.bucket.id
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern = "index.html"

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.bucket.id
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = [local.domain]

  logging_config {
    bucket = data.aws_s3_bucket.logs_bucket.bucket_regional_domain_name
    prefix = "${local.domain}/cloudfront/"
  }

  enabled             = true
  is_ipv6_enabled     = true
  wait_for_deployment = false
}

# NOTE: When adding simpledns, remember you can't CNAME the root record
resource "aws_route53_record" "record" {
  name    = local.domain
  type    = "CNAME"
  zone_id = data.aws_route53_zone.zone.zone_id
  ttl     = "300"

  records = [aws_cloudfront_distribution.distribution.domain_name]

  provider = aws.dns
}

output "stage" {
  value = var.stage
}

output "stage_env_vars" {
  value = var.stage_env_vars
}

output "bucket_name" {
  value = aws_s3_bucket.bucket.id
}

output "distribution_id" {
  value = aws_cloudfront_distribution.distribution.id
}
