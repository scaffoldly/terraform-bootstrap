terraform {
  required_version = ">= 0.14"
}

variable "repository" {}
variable "branch" {}
variable "stage_name" {
  default = ""
}
variable "stage_urls" {
  type = map(any)
}
variable "shared_env_vars" {
  type = map(any)
}

locals {
  stage_path = var.stage_name != "" ? "${var.stage_name}/" : ""
  env_suffix = var.stage_name != "" ? ".${var.stage_name}" : ""
}

resource "github_repository_file" "service_urls_json" {
  repository = var.repository
  branch     = var.branch
  file       = ".scaffoldly/${local.stage_path}service-urls.json"

  content = jsonencode(var.stage_urls)

  commit_message = "[Scaffoldly] Update ${local.stage_path}service-urls.json"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"

  lifecycle {
    ignore_changes = [
      branch
    ]
  }
}

resource "github_repository_file" "shared_env_vars_json" {
  repository = var.repository
  branch     = var.branch
  file       = ".scaffoldly/${local.stage_path}shared-env-vars.json"

  content = jsonencode(var.shared_env_vars)

  commit_message = "[Scaffoldly] Update ${local.stage_path}shared-env-vars.json"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"

  lifecycle {
    ignore_changes = [
      branch
    ]
  }
}

resource "github_repository_file" "env" {
  repository = var.repository
  branch     = var.branch
  file       = ".scaffoldly/.env${local.env_suffix}"

  content = <<EOF
# DO NOT EDIT. 
# THIS FILE IS MANAGED BY THE BOOTSTRAP PROJECT IN THIS ORGANIZATION.

service_urls=${jsonencode(var.stage_urls)}
shared_env_vars=${jsonencode(var.shared_env_vars)}
EOF

  commit_message = "[Scaffoldly] Update .env${local.env_suffix}"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"

  lifecycle {
    ignore_changes = [
      branch
    ]
  }
}
