variable "prefix" {}
variable "service_name" {}
variable "suffix" {}
variable "template" {}

locals {
  repository_name = "${var.prefix}-${var.service_name}-${var.suffix}"
  template_owner  = split("/", var.template)[0]
  template_repo   = split("/", var.template)[1]
}

resource "github_repository" "repository" {
  name = local.repository_name

  private                = true
  has_downloads          = false
  has_issues             = false
  has_projects           = false
  has_wiki               = false
  delete_branch_on_merge = true

  default_branch = "master" # TODO Change to main

  template {
    owner      = local.template_owner
    repository = local.template_repo
  }
}

// TODO: Branch protection

output "name" {
  value = github_repository.repository.name
}
