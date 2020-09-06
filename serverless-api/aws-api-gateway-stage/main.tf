variable "domain" {}
variable "name" {}
variable "stage" {}

resource "aws_api_gateway_rest_api" "api" {
  name = "${var.name}-${var.stage}"
}

resource "aws_cloudwatch_log_group" "group" {
  name = "/aws/apigateway/${var.name}-${var.stage}"
}

resource "aws_api_gateway_gateway_response" "response_cors" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  response_type = "DEFAULT_4XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'*'"
  }

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "/"
}

# TODO Health Check Resource + Logging + Etc
