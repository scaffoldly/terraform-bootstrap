variable "stage" {}
variable "repository_name" {}
variable "deployer_aws_access_key" {}
variable "deployer_aws_secret_key" {}
variable "bucket_name" {}

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

resource "github_actions_secret" "deployer_aws_bucket_name" {
  repository      = var.repository_name
  secret_name     = "${upper(var.stage)}_AWS_BUCKET_NAME"
  plaintext_value = var.bucket_name
}
