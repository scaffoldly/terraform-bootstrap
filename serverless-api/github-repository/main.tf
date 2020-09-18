variable "prefix" {}
variable "service_name" {}
variable "suffix" {}
variable "template_repo" {}

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

// TODO: Branch protection

output "name" {
  value = local.repository_name
}
