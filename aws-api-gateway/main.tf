variable "subdomain" {}
variable "stages" {
  type = list
}
variable "stage_domains" {
  type = map
}

resource "aws_iam_role" "api_gateway_cloudwatch" {
  name = "api-gateway-cloudwatch"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "api_gateway_cloudwatch" {
  name = "default"
  role = aws_iam_role.api_gateway_cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

module "domain" {
  source   = "./domain"
  for_each = var.stage_domains

  zone_id         = lookup(each.value, "zone_id", "unknown-zone-id")
  domain          = lookup(each.value, "domain", "unknown-domain")
  subdomain       = var.subdomain
  certificate_arn = lookup(each.value, "wildcard_certificate_arn", "unknown-arn")
}
