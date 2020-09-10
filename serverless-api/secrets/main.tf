variable "repository_name" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}

resource "github_actions_secret" "deployer_aws_access_key" {
  repository      = var.repository_name
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.aws_access_key
}

resource "github_actions_secret" "deployer_aws_secret_key" {
  repository      = var.repository_name
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.aws_secret_key
}
