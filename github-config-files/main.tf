variable "repository_name" {}
variable "stages" {
  type = list(any)
}
variable "stage_configs" {
  type = map(any)
}
variable "stage_urls" {
  type = map(any)
}
variable "shared_env_vars" {
  type = map(any)
}

data "github_repository" "repository" {
  name = var.repository_name
}

# locals {
#   stage_blah = flatten([
#     for service_name, service_config in var.stage_configs : {
#       service_name = for config in service_config : {
#         service_name = config.url
#       }
#     }
#   ])
# }

resource "github_repository_file" "readme" {
  repository = var.repository_name
  branch     = data.github_repository.repository.default_branch
  file       = ".scaffoldly/README.md"

  content = <<EOF
Scaffoldly Config Files
=======================
*NOTE: DO NOT MANUALLY EDIT THESE FILES*

They are managed by Terraform and the Bootstrap project in your oganization.

They can be updated indirectly by adjusting the configuration in that project.

More info: https://docs.scaffold.ly
EOF

  commit_message = "[Scaffoldly] Update Readme"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}

resource "github_repository_file" "shared_env_vars" {
  repository = var.repository_name
  branch     = data.github_repository.repository.default_branch
  file       = ".scaffoldly/shared-env.json"

  content = jsonencode(var.shared_env_vars)

  commit_message = "[Scaffoldly] Update shared-env"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}

resource "github_repository_file" "services" {
  repository = data.github_repository.repository.name
  branch     = data.github_repository.repository.default_branch
  file       = ".scaffoldly/services.json"

  content = jsonencode(var.stage_configs)

  commit_message = "[Scaffoldly] Update service map"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}

resource "github_repository_file" "stage_urls" {
  count = length(var.stages)

  repository = data.github_repository.repository.name
  branch     = data.github_repository.repository.default_branch
  file       = ".scaffoldly/services-${var.stages[count.index]}.json"

  content = jsonencode({
    for key, value in var.stage_urls :
    key => lookup(value, var.stages[count.index], "unknown-foo-bar")
  })

  commit_message = "[Scaffoldly] Update ${var.stages[count.index]} stage urls"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}

# module "stage_config_file" {
#   for_each = var.stage_configs
#   source   = "./stage-config-file"

#   repository = data.github_repository.repository.name
#   branch     = data.github_repository.repository.default_branch


# }
