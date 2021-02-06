variable "prefix" {}
variable "service_name" {}
variable "suffix" {}
variable "template_repo" {}
variable "stage_domains" {
  type = map(any)
}

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

  default_branch = "master" # TODO Change to main

  template {
    owner      = "scaffoldly"
    repository = var.template_repo
  }
}

resource "github_repository_file" "stage_domains" {
  repository = github_repository.repository.name
  branch     = "master" # TODO Change to main
  file       = ".scaffoldly/config/stage-domains.yml"

  content = templatefile("${path.module}/yaml.tpl", {
    yaml = yamlencode(var.stage_domain)
  })

  commit_message      = "[Scaffoldly] Update stage-domains.yml"
  commit_author       = "Scaffoldly Bootstrap"
  overwrite_on_create = true
}

// TODO: Branch protection

output "name" {
  value = local.repository_name
}
