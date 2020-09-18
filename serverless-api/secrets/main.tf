variable "stage" {}
variable "repository_name" {}
variable "deployer_aws_access_key" {}
variable "deployer_aws_secret_key" {}
variable "aws_rest_api_id" {}
variable "aws_rest_api_root_resource_id" {}

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
