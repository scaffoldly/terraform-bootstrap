terraform {
  required_version = ">= 0.15"

  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

variable "organization" {
  type = string
}
variable "repository_name" {
  type = string
}
variable "stages" {
  type = list(string)
}
variable "stage_urls" {
  type = map(map(string)) # Repo Name -> Stage -> URL
}
variable "stage_env_vars" {
  type = map(map(string)) # Stage -> Name -> Value
}
variable "shared_env_vars" {
  type = map(string)
}
variable "stage_domains" {
  # Using any so as the variable evolves/changes, everything still gets written
  type = any
}

data "github_repository" "repository" {
  full_name = "${var.organization}/${var.repository_name}"
}

module "stage_files" {
  count  = length(var.stages)
  source = "./stage-files"

  repository_name        = var.repository_name
  repository_description = data.github_repository.repository.description
  branch                 = data.github_repository.repository.default_branch

  stage_name = var.stages[count.index]

  stage_urls = {
    for key, value in var.stage_urls :
    key => lookup(value, var.stages[count.index], "unknown-url")
  }

  env_vars = lookup(var.stage_env_vars, var.stages[count.index])

  shared_env_vars = var.shared_env_vars
}

module "stage_files_default" {
  source = "./stage-files"

  organization           = var.organization
  repository_name        = var.repository_name
  repository_description = data.github_repository.repository.description
  branch                 = data.github_repository.repository.default_branch

  stage_name = ""

  stage_urls = {
    for key, value in var.stage_urls :
    key => lookup(value, "nonlive", "unknown-url") # TODO: Configurable default stage
  }

  env_vars = lookup(var.stage_env_vars, "nonlive")

  shared_env_vars = var.shared_env_vars
}

# This will trigger a nonlive release
resource "github_repository_file" "readme" {
  repository = var.repository_name
  branch     = data.github_repository.repository.default_branch
  file       = ".scaffoldly/README.md"

  content = <<EOF
# Scaffoldly Config Files

*NOTE: DO NOT MANUALLY EDIT THESE FILES*

These are managed by the `scaffoldly-bootstrap` project in your oganization.

They are by adjusting the configuration in that project.

For more info: https://docs.scaffold.ly/infrastructure/configuration-files

## Stages

```yaml
${yamlencode(var.stages)}
```

## Stage URLs

```yaml
${yamlencode(var.stage_urls)}
```

## Stage Env Vars (Higher precedence than Shared Env Vars)

```yaml
${yamlencode(var.stage_env_vars)}
```

## Shared Env Vars

```yaml
${yamlencode(var.shared_env_vars)}
```

## Full `stage_domains` Config

_NOTE:_ This map isn't *directly* written to any configuration files and is 
meant to be informative for service owners visibility of what's availalbe
on the platform.

```yaml
${yamlencode(var.stage_domains)}
```

If any of this configuration needs to be exported, an issue can be raised on the
[Scaffoldly Terraform Bootstrap](https://github.com/scaffoldly/terraform-scaffoldly-bootstrap)
project.

EOF

  // Use a different prefix so nonlive releases get triggered
  commit_message = "[scaffoldly-bootstrap] Update Platform Configuration"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"

  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      branch
    ]
  }

  depends_on = [
    module.stage_files,
    module.stage_files_default
  ]
}
