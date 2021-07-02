terraform {
  required_version = ">= 0.15"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.dns]
    }
  }
}

variable "stage" {
  type = string
}

variable "root_email" {
  type = string
}

variable "mail_domain" {
  type = string
}

variable "dns_provider" {
  type = string
}

variable "dns_domain_id" {
  type = string
}

variable "rule_set_name" {
  type = string
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_ses_email_identity" "example" {
  email = var.root_email
}

resource "aws_ses_domain_identity" "identity" {
  domain = var.mail_domain
}

resource "aws_ses_domain_dkim" "dkim" {
  domain = aws_ses_domain_identity.identity.domain
}

resource "aws_ses_domain_mail_from" "mail_from" {
  domain           = aws_ses_domain_identity.identity.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.identity.domain}"
}

resource "aws_ses_configuration_set" "configuration_set" {
  name = var.stage
}

data "aws_iam_policy_document" "event_policy" {
  statement {
    actions = [
      "sns:Publish",
    ]

    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "ses.amazonaws.com",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceOwner"

      values = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_sns_topic" "events" {
  name         = "${var.stage}-email-events"
  display_name = "${var.stage}-email-events"

  policy = data.aws_iam_policy_document.event_policy.json
}

resource "aws_sns_topic" "bounce" {
  name         = "${var.stage}-bounce-events"
  display_name = "${var.stage}-bounce-events"

  policy = data.aws_iam_policy_document.event_policy.json
}

resource "aws_sns_topic" "complaint" {
  name         = "${var.stage}-complaint-events"
  display_name = "${var.stage}-complaint-events"

  policy = data.aws_iam_policy_document.event_policy.json
}

resource "aws_sns_topic_subscription" "root_email_compaints" {
  topic_arn = aws_sns_topic.complaint.arn
  protocol  = "email"
  endpoint  = var.root_email
}

resource "aws_ses_event_destination" "sns_destination" {
  name                   = var.stage
  configuration_set_name = aws_ses_configuration_set.configuration_set.name
  enabled                = true
  matching_types         = ["send", "reject", "delivery", "open", "click", "renderingFailure"]

  sns_destination {
    topic_arn = aws_sns_topic.events.arn
  }
}

resource "aws_ses_event_destination" "sns_destination_bounce" {
  name                   = var.stage
  configuration_set_name = aws_ses_configuration_set.configuration_set.name
  enabled                = true
  matching_types         = ["bounce"]

  sns_destination {
    topic_arn = aws_sns_topic.bounce.arn
  }
}

resource "aws_ses_event_destination" "sns_destination_complaint" {
  name                   = var.stage
  configuration_set_name = aws_ses_configuration_set.configuration_set.name
  enabled                = true
  matching_types         = ["complaint"]

  sns_destination {
    topic_arn = aws_sns_topic.complaint.arn
  }
}

resource "aws_ses_identity_notification_topic" "bounce" {
  topic_arn                = aws_sns_topic.bounce.arn
  notification_type        = "Bounce"
  identity                 = aws_ses_domain_identity.identity.domain
  include_original_headers = true
}

resource "aws_ses_identity_notification_topic" "complaint" {
  topic_arn                = aws_sns_topic.complaint.arn
  notification_type        = "Complaint"
  identity                 = aws_ses_domain_identity.identity.domain
  include_original_headers = true
}

resource "aws_ses_identity_notification_topic" "delivery" {
  topic_arn                = aws_sns_topic.events.arn
  notification_type        = "Delivery"
  identity                 = aws_ses_domain_identity.identity.domain
  include_original_headers = true
}

resource "aws_route53_record" "mail_from_mx" {
  zone_id = var.dns_domain_id
  name    = aws_ses_domain_mail_from.mail_from.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${data.aws_region.current.name}.amazonses.com"]

  provider = aws.dns
}

resource "aws_route53_record" "mail_from_txt" {
  zone_id = var.dns_domain_id
  name    = aws_ses_domain_mail_from.mail_from.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]

  provider = aws.dns
}

resource "aws_route53_record" "verification_record" {
  zone_id = var.dns_domain_id
  name    = "_amazonses.${var.mail_domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.identity.verification_token]

  provider = aws.dns
}

resource "aws_route53_record" "dkim_record" {
  count   = 3
  zone_id = var.dns_domain_id
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${var.mail_domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]

  provider = aws.dns
}

resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"

  depends_on = [
    aws_route53_record.verification_record
  ]
}

resource "aws_ses_receipt_rule" "bounce_noreply" {
  name          = "${var.stage}-bounce-noreply"
  rule_set_name = var.rule_set_name
  recipients    = ["no-reply@${var.mail_domain}"]
  enabled       = true
  scan_enabled  = true

  bounce_action {
    message         = "Mailbox does not exist"
    sender          = "no-reply@${var.mail_domain}"
    smtp_reply_code = "550"
    status_code     = "5.1.1"
    topic_arn       = aws_sns_topic.events.arn
    position        = 1
  }

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}
