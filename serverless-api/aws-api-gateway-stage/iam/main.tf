variable "name" {}
variable "stage" {}

data "aws_iam_policy_document" "base" {
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "cloudwatch:PutMetricData",
      "xray:PutTelemetryRecords",
      "xray:PutTraceSegments",
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
    ]

    resources = [
      "arn:*:dynamodb:*:*:table/${var.stage}-${var.name}*"
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:*:secretsmanager:*:*:secret:lambda/${var.stage}/${var.name}*",
    ]
  }
}

resource "aws_iam_role" "role" {
  name = "${var.name}-${var.stage}"

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
