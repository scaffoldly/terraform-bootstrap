terraform {
  required_version = ">= 0.14"
}

provider "github" {
  alias = "org"
}

variable "stage" {
  type = string
}
variable "organization" {
  type = string
}
variable "repository_name" {
  type = string
}
variable "bucket_name" {
  type = string
}
variable "distribution_id" {
  type = string
}

data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "base" {
  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:Describe*",
      "s3:Put*",
      "s3:Delete*",
      "cloudfront:CreateInvalidation",
    ]

    resources = [
      "arn:*:s3:::${var.bucket_name}",
      "arn:*:s3:::${var.bucket_name}/*",
      "arn:*:cloudfront::*:distribution/${var.distribution_id}",
    ]
  }

  statement {
    effect = "Deny"

    actions = [
      "s3:DeleteBucket",
      "s3:DeleteObjectVersion"
    ]

    resources = [
      "arn:*:s3:::${var.bucket_name}",
      "arn:*:s3:::${var.bucket_name}/*",
    ]
  }
}

resource "aws_iam_user" "user" {
  name = "${var.repository_name}-${var.stage}-deployer"
}

resource "aws_iam_user_policy" "policy" {
  name   = "base-policy"
  user   = aws_iam_user.user.name
  policy = data.aws_iam_policy_document.base.json
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name

  depends_on = [aws_iam_user_policy.policy]
}

resource "github_actions_secret" "deployer_aws_partition" {
  repository      = "${var.organization}/${var.repository_name}"
  secret_name     = "${upper(var.stage)}_AWS_PARTITION"
  plaintext_value = data.aws_partition.current.partition

  provider = github.org
}

resource "github_actions_secret" "deployer_aws_account_id" {
  repository      = "${var.organization}/${var.repository_name}"
  secret_name     = "${upper(var.stage)}_AWS_ACCOUNT_ID"
  plaintext_value = data.aws_caller_identity.current.account_id

  provider = github.org
}

resource "github_actions_secret" "deployer_aws_default_region" {
  repository      = "${var.organization}/${var.repository_name}"
  secret_name     = "${upper(var.stage)}_AWS_DEFAULT_REGION"
  plaintext_value = data.aws_region.current.name

  provider = github.org
}

resource "github_actions_secret" "deployer_aws_access_key" {
  repository      = "${var.organization}/${var.repository_name}"
  secret_name     = "${upper(var.stage)}_AWS_ACCESS_KEY_ID"
  plaintext_value = aws_iam_access_key.access_key.id

  provider = github.org
}

resource "github_actions_secret" "deployer_aws_secret_key" {
  repository      = "${var.organization}/${var.repository_name}"
  secret_name     = "${upper(var.stage)}_AWS_SECRET_ACCESS_KEY"
  plaintext_value = aws_iam_access_key.access_key.secret

  provider = github.org
}

resource "github_actions_secret" "deployer_aws_bucket_name" {
  repository      = "${var.organization}/${var.repository_name}"
  secret_name     = "${upper(var.stage)}_AWS_BUCKET_NAME"
  plaintext_value = var.bucket_name

  provider = github.org
}

resource "github_actions_secret" "deployer_aws_cloudfont_distribution_id" {
  repository      = "${var.organization}/${var.repository_name}"
  secret_name     = "${upper(var.stage)}_AWS_CLOUDFRONT_DISTRIBUTION_ID"
  plaintext_value = var.distribution_id

  provider = github.org
}
