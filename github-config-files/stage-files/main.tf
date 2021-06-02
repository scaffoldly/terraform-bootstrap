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
variable "service_name" {
  type = string
}
variable "repository_description" {
  type    = string
  default = ""
}
variable "branch" {
  type = string
}
variable "stage_name" {
  type    = string
  default = ""
}
variable "stage_config" {
  type = map(map(string))
}
variable "env_vars" {
  type = map(string)
}
variable "shared_env_vars" {
  type = map(string)
}

locals {
  stage_path = var.stage_name != "" ? "${var.stage_name}/" : ""
  env_suffix = var.stage_name != "" ? ".${var.stage_name}" : ""
  env_vars = merge(
    {
      SERVICE_NAME              = var.service_name
      APPLICATION_NAME          = var.repository_name
      APPLICATION_FRIENDLY_NAME = var.repository_description != "" ? var.repository_description : var.repository_name
    },
    var.shared_env_vars,
    var.env_vars,
  )
}

resource "github_repository_file" "services_json" {
  repository = var.repository_name
  branch     = var.branch
  file       = ".scaffoldly/${local.stage_path}services.json"

  content = jsonencode(var.stage_config)

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

stage_config=${jsonencode(var.stage_config)}
env_vars=${jsonencode(local.env_vars)}
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
