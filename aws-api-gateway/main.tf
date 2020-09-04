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
  count = length(aws_api_gateway_domain_name.domain)

  name    = aws_api_gateway_domain_name[count.index].domain_name
  type    = "A"
  zone_id = aws_api_gateway_domain_name[count.index].tags.zone_id

  alias {
    name                   = aws_api_gateway_domain_name[count.index].domain_name_configuration[0].target_domain_name
    zone_id                = aws_api_gateway_domain_name[count.index].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
