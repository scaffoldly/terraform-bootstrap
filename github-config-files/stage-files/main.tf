terraform {
  required_version = ">= 0.15"

  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

variable "repository_name" {
  type = string
}
variable "branch" {
  type = string
}
variable "stage_name" {
  type    = string
  default = ""
}
variable "stage_urls" {
  type = map(any)
}
variable "env_vars" {
  type    = map(any)
  default = {}
}
variable "shared_env_vars" {
  type = map(any)
}

locals {
  stage_path = var.stage_name != "" ? "${var.stage_name}/" : ""
  env_suffix = var.stage_name != "" ? ".${var.stage_name}" : ""
  env_vars   = merge(var.shared_env_vars, var.env_vars)
}

resource "github_repository_file" "service_urls_json" {
  repository = var.repository_name
  branch     = var.branch
  file       = ".scaffoldly/${local.stage_path}service-urls.json"

  content = jsonencode(var.stage_urls)

  commit_message = "[Scaffoldly] Update ${local.stage_path}service-urls.json"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"

  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      branch
    ]
  }
}

resource "github_repository_file" "env_vars_json" {
  repository = var.repository_name
  branch     = var.branch
  file       = ".scaffoldly/${local.stage_path}env-vars.json"

  content = jsonencode(local.env_vars)

  commit_message = "[Scaffoldly] Update ${local.stage_path}env-vars.json"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"

  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      branch
    ]
  }
}

resource "github_repository_file" "env" {
  repository = var.repository_name
  branch     = var.branch
  file       = ".scaffoldly/.env${local.env_suffix}"

  content = <<EOF
# DO NOT EDIT. 
# THIS FILE IS MANAGED BY THE BOOTSTRAP PROJECT IN THIS ORGANIZATION.

service_urls=${jsonencode(var.stage_urls)}
env_vars=${jsonencode(var.env_vars)}
EOF

  commit_message = "[Scaffoldly] Update .env${local.env_suffix}"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"

  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      branch
    ]
  }
}
