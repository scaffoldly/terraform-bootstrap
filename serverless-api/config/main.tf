variable "repository_name" {}
variable "stage_domains" {
  type = map(any)
}
variable "shared_env_vars" {
  type = map(any)
}

data "github_repository" "repository" {
  name = var.repository_name
}

resource "github_repository_file" "stage_domains" {
  repository = var.repository_name
  branch     = data.github_repository.repository.default_branch
  file       = ".scaffoldly/config/stage-domains.yml"

  content = templatefile("${path.module}/yaml.tpl", {
    yaml = yamlencode(var.stage_domains)
  })

  commit_message = "[Scaffoldly] Update config: stage-domains.yml"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}

resource "github_repository_file" "shared_env_vars" {
  repository = var.repository_name
  branch     = data.github_repository.repository.default_branch
  file       = ".scaffoldly/env/shared.yml"

  content = templatefile("${path.module}/yaml.tpl", {
    yaml = yamlencode(var.shared_env_vars)
  })

  commit_message = "[Scaffoldly] Update env: shared.yml"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}
