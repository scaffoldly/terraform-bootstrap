variable "prefix" {}
variable "service_name" {}
variable "suffix" {}
variable "template_repo" {}

variable "stage_domains" {
  type = map(any)
}
variable "serverless_apis" {
  type = map(any)
}
variable "shared_env_vars" {
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
    yaml = yamlencode(var.stage_domains)
  })

  commit_message = "[Scaffoldly] Update config: stage-domains.yml"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}

resource "github_repository_file" "serverless_apis" {
  repository = github_repository.repository.name
  branch     = "master" # TODO Change to main
  file       = ".scaffoldly/config/serverless-apis.yml"

  content = templatefile("${path.module}/yaml.tpl", {
    yaml = yamlencode(var.serverless_apis)
  })

  commit_message = "[Scaffoldly] Update config: serverless-apis.yml"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}

resource "github_repository_file" "shared_env_vars" {
  repository = github_repository.repository.name
  branch     = "master" # TODO Change to main
  file       = ".scaffoldly/env/shared.yml"

  content = templatefile("${path.module}/yaml.tpl", {
    yaml = yamlencode(var.shared_env_vars)
  })

  commit_message = "[Scaffoldly] Update env: shared.yml"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}

// TODO: Branch protection

output "name" {
  value = local.repository_name
}
