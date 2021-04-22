terraform {
  required_version = ">= 0.15"
}

variable "repository_name" {
  type = string
}
variable "stage" {
  type = string
}

data "aws_iam_policy_document" "base" {
  # TODO: A-la-carte choices of AWS services that CF manages

  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "cloudwatch:PutMetricData",
      "xray:PutTelemetryRecords",
      "xray:PutTraceSegments",
      "ses:SendEmail",
      "ses:SendRawEmail",
      "ses:List*",
      "ses:Describe*",
      "ses:Get*",
      "ses:*Template*",
    ]

    resources = ["*"] # TODO Be more specific
  }

  statement {
    actions = [
      "dynamodb:List*",
      "dynamodb:Describe*",
      "dynamodb:*Item*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListShards",
      "dynamodb:ListStreams",
    ]

    resources = [
      "arn:*:dynamodb:*:*:table/${var.stage}-${var.repository_name}*"
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
    ]

    resources = [
      "arn:*:secretsmanager:*:*:secret:lambda/${var.stage}/${var.repository_name}*",
    ]
  }
}

resource "aws_iam_role" "role" {
  name = "${var.repository_name}-${var.stage}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "base" {
  name   = "base"
  role   = aws_iam_role.role.name
  policy = data.aws_iam_policy_document.base.json
}
