variable "service_name" {}
variable "repository_name" {}
variable "stage_config" {
  type = map(any)
}

data "github_repository" "repository" {
  name = var.repository_name
}

resource "github_repository_file" "serverless_apis" {
  repository = data.github_repository.repository.name
  branch     = data.github_repository.repository.default_branch
  file       = ".scaffoldly/config/${var.service_name}.yml"

  content = templatefile("${path.module}/yaml.tpl", {
    yaml = yamlencode(var.stage_config)
  })

  commit_message = "[Scaffoldly] Update config: ${var.service_name}.yml"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}
