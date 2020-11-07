variable "account_name" {}
variable "name" {}
variable "stage" {}
variable "domain" {}
variable "subdomain_suffix" {}
variable "certificate_arn" {}

data "aws_partition" "current" {}
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
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// TODO WRITE FOR DEPLOYER
data "aws_iam_policy_document" "bucket_policy" {
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

  custom_error_response {
    error_code         = 403
    response_code      = 403
    response_page_path = "/forbidden.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/error.html"
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

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = [local.domain]

  logging_config {
    bucket = data.aws_s3_bucket.logs_bucket.bucket_regional_domain_name
  }

  enabled             = true
  is_ipv6_enabled     = true
  wait_for_deployment = false
}
