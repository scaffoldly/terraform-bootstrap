variable "service_name" {}
variable "repository_name" {}
variable "stage_configs" {
  type = map(any)
}

data "github_repository" "repository" {
  name = var.repository_name
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
