terraform {
  required_version = ">= 0.15"
}

variable "domain" {
  type = string
}
variable "name" {
  type = string
}
variable "stage" {
  type = string
}
variable "stage_env_vars" {
  type = map(string)
}
variable "repository_name" {
  type = string
}

locals {
  cors_response_types = {
    ACCESS_DENIED = {
      status_code = 403
    }
    API_CONFIGURATION_ERROR = {
      status_code = 500
    }
    AUTHORIZER_CONFIGURATION_ERROR = {
      status_code = 500
    }
    AUTHORIZER_FAILURE = {
      status_code = 500
    }
    BAD_REQUEST_PARAMETERS = {
      status_code = 400
    }
    BAD_REQUEST_BODY = {
      status_code = 400
    }
    DEFAULT_4XX = {
      status_code = null
    }
    DEFAULT_5XX = {
      status_code = null
    }
    EXPIRED_TOKEN = {
      status_code = 403
    }
    INTEGRATION_FAILURE = {
      status_code = 504
    }
    INTEGRATION_TIMEOUT = {
      status_code = 504
    }
    INVALID_API_KEY = {
      status_code = 403
    }
    INVALID_SIGNATURE = {
      status_code = 403
    }
    MISSING_AUTHENTICATION_TOKEN = {
      status_code = 403
    }
    QUOTA_EXCEEDED = {
      status_code = 429
    }
    REQUEST_TOO_LARGE = {
      status_code = 413
    }
    RESOURCE_NOT_FOUND = {
      status_code = 404
    }
    THROTTLED = {
      status_code = 429
    }
    UNAUTHORIZED = {
      status_code = 401
    }
    UNSUPPORTED_MEDIA_TYPE = {
      status_code = 415
    }
    WAF_FILTERED = {
      status_code = 403
    }
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name = "${var.name}-${var.stage}"
}

resource "aws_cloudwatch_log_group" "group" {
  name = "/aws/apigateway/${var.name}-${var.stage}"
}

resource "aws_cloudwatch_log_group" "access_logs_group" {
  name = "/aws/apigateway/${var.name}-${var.stage}-access-logs"
}

resource "aws_cloudwatch_log_group" "execution_group" {
  name = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api.id}/${var.stage}"
}

resource "aws_api_gateway_gateway_response" "cors_responses" {
  for_each = local.cors_response_types

  rest_api_id   = aws_api_gateway_rest_api.api.id
  response_type = each.key
  status_code   = each.value.status_code

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'*'"
  }

  response_templates = {
    "application/json" = "{\"error\":\"${each.key}\",\"message\":$context.error.messageString,\"context\":{}}"
  }
}

resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "health_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "health_get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "health_get_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "health_get_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  status_code = aws_api_gateway_method_response.health_get_response_200.status_code

  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,HEAD'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_resource" "not_found" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "404"
}

resource "aws_api_gateway_method" "not_found_any" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.not_found.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "not_found_any" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.not_found.id
  http_method = aws_api_gateway_method.not_found_any.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 404}"
  }
}

resource "aws_api_gateway_method_response" "not_found_any_response_404" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.not_found.id
  http_method = aws_api_gateway_method.not_found_any.http_method
  status_code = "404"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "not_found_any_response_404" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.not_found.id
  http_method = aws_api_gateway_method.not_found_any.http_method
  status_code = aws_api_gateway_method_response.not_found_any_response_404.status_code

  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,HEAD,PUT,POST,PATCH,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_resource" "catchall" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "catchall_any" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.catchall.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "catchall_any" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.catchall.id
  http_method             = aws_api_gateway_method.catchall_any.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  connection_type         = "INTERNET"
  passthrough_behavior    = "WHEN_NO_MATCH"

  uri = "https://${var.domain}/${var.name}/404"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on        = [aws_api_gateway_integration.health_get]
  rest_api_id       = aws_api_gateway_rest_api.api.id
  stage_name        = "bootstrap"
  stage_description = "A basic stage created to remediate a race condition in API Gateway"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  stage_name    = var.stage
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id

  xray_tracing_enabled = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.access_logs_group.arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }

  depends_on = [aws_cloudwatch_log_group.execution_group]

  lifecycle {
    ignore_changes = [
      deployment_id
    ]
  }
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"

    throttling_rate_limit  = -1
    throttling_burst_limit = -1
  }
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  domain_name = var.domain
  base_path   = var.name
}

module "iam" { # TODO Rename
  source = "./iam"

  repository_name = var.repository_name
  stage           = var.stage
}

output "api_id" {
  value = aws_api_gateway_rest_api.api.id
}

output "root_resource_id" {
  value = aws_api_gateway_rest_api.api.root_resource_id
}

output "name" {
  value = var.stage
}

output "stage_env_vars" {
  value = var.stage_env_vars
}

output "domain" {
  value = "https://${var.domain}"
}

output "base_path" {
  value = "/${var.name}"
}

output "url" {
  value = "https://${var.domain}/${var.name}"
}
