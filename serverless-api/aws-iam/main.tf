terraform {
  required_version = ">= 0.14"
}

variable "repository_name" {
  type = string
}

# Inspiration drawn from:
# https://medium.com/@dav009/serverless-framework-minimal-iam-role-permissions-ba34bec0154e
data "aws_iam_policy_document" "cloudformation" {
  statement {
    actions = [
      "iam:PassRole"
    ]

    resources = [
      "arn:*:iam::*:role/${var.repository_name}*"
    ]
  }

  statement {
    actions = [
      "cloudformation:Describe*",
      "cloudformation:List*",
      "cloudformation:Get*",
      "cloudformation:PreviewStackUpdate",
      "cloudformation:CreateStack",
      "cloudformation:UpdateStack"
    ]

    resources = [
      "arn:*:cloudformation:*:*:stack/${var.repository_name}*"
    ]
  }

  statement {
    actions = [
      "cloudformation:ValidateTemplate"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "arn:*:s3:::${var.repository_name}*",
      "arn:*:s3:::${var.repository_name}*/*",
    ]
  }

  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:CreateBucket",
      "s3:*Notification*",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "apigateway:GET",
      "apigateway:HEAD",
      "apigateway:OPTIONS",
      "apigateway:PATCH",
      "apigateway:POST",
      "apigateway:PUT",
      "apigateway:DELETE"
    ]

    resources = [
      "arn:*:apigateway:*::/apis*",
      "arn:*:apigateway:*::/apis/*",
      "arn:*:apigateway:*::/restapis*",
      "arn:*:apigateway:*::/restapis/*",
      "arn:*:apigateway:*::/apikeys*",
      "arn:*:apigateway:*::/apikeys/*",
      "arn:*:apigateway:*::/usageplans*",
      "arn:*:apigateway:*::/usageplans/*",
    ]
  }

  statement {
    actions = [
      "logs:DescribeLogGroups"
    ]

    resources = [
      "arn:*:logs:*:*:log-group::log-stream:*"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
      "logs:DescribeLogStreams",
      "logs:FilterLogEvents"
    ]

    resources = [
      "arn:*:logs:*:*:log-group:/aws/lambda/${var.repository_name}*:log-stream:*",
    ]
  }

  statement {
    actions = [
      "events:DescribeRule",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
      "events:DeleteRule"
    ]

    resources = [
      "arn:*:events:*:*:rule/${var.repository_name}*"
    ]
  }

  statement {
    actions = [
      "lambda:Get*",
      "lambda:Create*",
      "lambda:Delete*",
      "lambda:Update*",
      "lambda:List*",
      "lambda:Publish*",
      "lambda:Add*",
      "lambda:Remove*",
      "lambda:Invoke*",
      "lambda:Tag*",
      "lambda:Untag*",
    ]

    resources = [
      "arn:*:lambda:*:*:function:${var.repository_name}*"
    ]
  }

  statement {
    actions = [
      "lambda:*"
    ]

    resources = [
      "arn:*:lambda:*:*:function:${var.repository_name}*"
    ]
  }

  statement {
    actions = [
      "lambda:*EventSourceMapping*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "dynamodb:List*",
      "dynamodb:Describe*",
      "dynamodb:*Tag*",
      "dynamodb:CreateTable*",
      "dynamodb:DeleteTable*",
      "dynamodb:RestoreTable*",
      "dynamodb:UpdateTable*",
      "dynamodb:UpdateContinuousBackups",
      "dynamodb:GetShardIterator",
      "dynamodb:*TimeToLive*",
    ]

    resources = [
      "arn:*:dynamodb:*:*:table/live-${var.repository_name}*",
      "arn:*:dynamodb:*:*:table/nonlive-${var.repository_name}*"
    ]
  }

  statement {
    actions = [
      "xray:*Group*",
      "xray:*SamplingRule*",
      "xray:*EncryptionConfig*"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "cloudformation" {
  name = "${var.repository_name}-cloudformation"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "cloudformation.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudformation_policy" {
  name   = "base-policy"
  role   = aws_iam_role.cloudformation.name
  policy = data.aws_iam_policy_document.cloudformation.json
}

data "aws_iam_policy_document" "assume_cloudformation_role" {
  statement {
    actions = [
      "iam:PassRole"
    ]

    resources = [
      aws_iam_role.cloudformation.arn
    ]
  }
}

data "aws_iam_policy_document" "deployer" {
  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "arn:*:s3:::${var.repository_name}*",
      "arn:*:s3:::${var.repository_name}*/*"
    ]
  }

  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:CreateBucket",
      "s3:*Notification*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:UpdateStack",
      "cloudformation:DeleteStack"
    ]

    resources = [
      "arn:*:cloudformation:*:*:stack/${var.repository_name}*"
    ]
  }

  statement {
    actions = [
      "cloudformation:Describe*",
      "cloudformation:List*",
      "cloudformation:Get*",
      "cloudformation:PreviewStackUpdate",
      "cloudformation:ValidateTemplate"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "apigateway:GET",
    ]

    resources = [
      "arn:*:apigateway:*::/apikeys*",
      "arn:*:apigateway:*::/apikeys/*",
    ]
  }

  statement {
    actions = [
      "apigateway:GET",
      "apigateway:DELETE",
      "apigateway:POST",
      "apigateway:PATCH",
    ]

    resources = [
      "arn:*:apigateway:*::/domainnames*",
      "arn:*:apigateway:*::/domainnames/*",
    ]
  }

  statement {
    actions = [
      "lambda:*",
    ]

    resources = [
      "arn:*:lambda:*:*:function:${var.repository_name}*",
    ]
  }

  statement {
    actions = [
      "xray:*Group*",
      "xray:*SamplingRule*",
      "xray:*EncryptionConfig*"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_user" "user" {
  name = "${var.repository_name}-deployer"
}

resource "aws_iam_user_policy" "policy" {
  name   = "base-policy"
  user   = aws_iam_user.user.name
  policy = data.aws_iam_policy_document.deployer.json
}

resource "aws_iam_user_policy" "assume_cloudformation_role" {
  name   = "assume-cloudformation-role"
  user   = aws_iam_user.user.name
  policy = data.aws_iam_policy_document.assume_cloudformation_role.json
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name

  depends_on = [
    aws_iam_user_policy.policy,
    aws_iam_user_policy.assume_cloudformation_role
  ]
}

output "deployer_access_key" {
  value = aws_iam_access_key.access_key.id
}

output "deployer_secret_key" {
  value = aws_iam_access_key.access_key.secret
}
