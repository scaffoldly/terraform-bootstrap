terraform {
  required_version = ">= 0.14"
}

variable "name" {
  type = string
}
variable "template" {
  type = string
}

locals {
  template_owner = split("/", var.template)[0]
  template_repo  = split("/", var.template)[1]
}

# TODO: Github Users / Teams / CODEOWNERS

resource "github_repository" "repository" {
  name = var.name

  private                = true
  has_downloads          = false
  has_issues             = false
  has_projects           = false
  has_wiki               = false
  delete_branch_on_merge = true

  template {
    owner      = local.template_owner
    repository = local.template_repo
  }

  lifecycle {
    ignore_changes = [
      template,
      default_branch
    ]
  }
}

// TODO: Branch protection

output "name" {
  value = github_repository.repository.name
}
