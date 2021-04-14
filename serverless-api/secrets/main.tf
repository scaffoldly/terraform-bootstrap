terraform {
  required_version = ">= 0.15"

  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

variable "stage" {
  type = string
}
variable "repository_name" {
  type = string
}
variable "deployer_aws_access_key" {
  type = string
}
variable "deployer_aws_secret_key" {
  type      = string
  sensitive = true
}
variable "aws_rest_api_id" {
  type = string
}
variable "aws_rest_api_root_resource_id" {
  type = string
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

resource "github_actions_secret" "deployer_aws_partition" {
  repository      = var.repository_name
  secret_name     = "${upper(var.stage)}_AWS_PARTITION"
  plaintext_value = data.aws_partition.current.partition
}

resource "github_actions_secret" "deployer_aws_account_id" {
  repository      = var.repository_name
  secret_name     = "${upper(var.stage)}_AWS_ACCOUNT_ID"
  plaintext_value = data.aws_caller_identity.current.account_id
}

resource "github_actions_secret" "deployer_aws_access_key" {
  repository      = var.repository_name
  secret_name     = "${upper(var.stage)}_AWS_ACCESS_KEY_ID"
  plaintext_value = var.deployer_aws_access_key
}

resource "github_actions_secret" "deployer_aws_secret_key" {
  repository      = var.repository_name
  secret_name     = "${upper(var.stage)}_AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.deployer_aws_secret_key
}

resource "github_actions_secret" "deployer_aws_rest_api_id" {
  repository      = var.repository_name
  secret_name     = "${upper(var.stage)}_AWS_REST_API_ID"
  plaintext_value = var.aws_rest_api_id
}

resource "github_actions_secret" "deployer_aws_rest_api_root_resource_id" {
  repository      = var.repository_name
  secret_name     = "${upper(var.stage)}_AWS_REST_API_ROOT_RESOURCE_ID"
  plaintext_value = var.aws_rest_api_root_resource_id
}

// TODO create a secrets repo and load them in from there
// TOOD switch to repository full name?
resource "aws_secretsmanager_secret" "secret" {
  name = "lambda/${var.stage}/${var.repository_name}"
}

resource "aws_secretsmanager_secret_version" "value" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode({})

  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}
