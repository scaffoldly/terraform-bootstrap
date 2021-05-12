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

//
// Catchall to return 404s (or a 200)
// This resource is a mock which will return status code 404 by default
// It will return 200 if 'proxy' isn't set in the headers/path/querystring
//    and the request is a GET, HEAD, or OPTIONS
//
// This catchall is used by aws_api_gateway_resource.proxy, which will catch
//    all non-matching requests to the API, and make an HTTP request to /catchall
//    with 'proxy' added to the path with the requested path
//
// TODO: Response body on 404s displaying the invalid path
//
resource "aws_api_gateway_resource" "catchall" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "catchall"
}

resource "aws_api_gateway_method" "catchall" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.catchall.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "catchall" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.catchall.id
  http_method          = aws_api_gateway_method.catchall.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = <<EOF
#set($statusCode = 404)
#if($input.params('proxy') == "" && ($context.httpMethod == "GET" || $context.httpMethod == "HEAD" || $context.httpMethod == "OPTIONS"))
    #set($statusCode = 200)
#end
"{\"statusCode\": $statusCode)}"
EOF
  }
}

resource "aws_api_gateway_method_response" "catchall_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.catchall.id
  http_method = aws_api_gateway_method.catchall.http_method
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

resource "aws_api_gateway_method_response" "catchall_404" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.catchall.id
  http_method = aws_api_gateway_method.catchall.http_method
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

resource "aws_api_gateway_integration_response" "catchall_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.catchall.id
  http_method = aws_api_gateway_method.catchall.http_method
  status_code = aws_api_gateway_method_response.catchall_200.status_code

  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,HEAD,PUT,POST,PATCH,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_integration_response" "catchall_404" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.catchall.id
  http_method = aws_api_gateway_method.catchall.http_method
  status_code = aws_api_gateway_method_response.catchall_404.status_code

  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,HEAD,PUT,POST,PATCH,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  connection_type         = "INTERNET"

  uri = "https://${var.domain}/${var.name}/catchall?proxy={proxy}"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id       = aws_api_gateway_rest_api.api.id
  stage_name        = "bootstrap"
  stage_description = "A basic stage created to remediate a race condition in API Gateway"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration_response.catchall_200,
    aws_api_gateway_integration_response.catchall_404,
    aws_api_gateway_integration.proxy
  ]
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
