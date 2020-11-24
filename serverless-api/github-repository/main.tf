variable "prefix" {}
variable "service_name" {}
variable "suffix" {}
variable "template_repo" {}
variable "additional_env_vars" {}

locals {
  repository_name = "${var.prefix}-${var.service_name}-${var.suffix}"
}

resource "github_repository" "repository" {
  name = local.repository_name

  private                = true
  has_downloads          = false
  has_issues             = false
  has_projects           = false
  has_wiki               = false
  delete_branch_on_merge = true

  default_branch = "master"

  template {
    owner      = "scaffoldly"
    repository = var.template_repo
  }
}

resource "github_actions_secret" "additional_env_vars" {
  repository      = github_repository.repository.full_name
  secret_name     = "ADDITIONAL_ENV_VARS"
  plaintext_value = base64encode(jsonencode(var.additional_env_vars))
}

// TODO: Branch protection

output "name" {
  value = local.repository_name
}
