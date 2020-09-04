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

# TODO: Wait for wildcard certificate ARN
resource "aws_api_gateway_domain_name" "domain" {
  for_each = var.stage_domains

  security_policy = "TLS_1_2"
  certificate_arn = lookup(each.value, "wildcard_certificate_arn", "unknown-arn")
  domain_name     = "api.${lookup(each.value, "domain", "unknown-domain")}"

  tags = {
    zone_id = lookup(each.value, "zone_id", "unknown-zone-id")
  }
}

resource "aws_route53_record" "api_record" {
  for_each = toset(aws_api_gateway_domain_name.domain)

  name    = each.value.domain_name
  type    = "A"
  zone_id = lookup(each.tags, "zone_id", "unknown-zone-id")

  alias {
    name                   = each.value.domain_name_configuration[0].target_domain_name
    zone_id                = each.value.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
