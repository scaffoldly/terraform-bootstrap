variable "repository" {}
variable "branch" {}
variable "stage_name" {}
variable "stage_urls" {
  type = map(any)
}

resource "github_repository_file" "json" {
  repository = var.repository
  branch     = var.branch
  file       = ".scaffoldly/${var.stage_name}/service-urls.json"

  content = jsonencode(var.stage_urls)

  commit_message = "[Scaffoldly] Update ${var.stage_name}/service-urls.json"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}

resource "github_repository_file" "env" {
  repository = var.repository
  branch     = var.branch
  file       = ".scaffoldly/${var.stage_name}/service-urls.env"

  content = <<EOF
service_urls=${jsonencode(var.stage_urls)}"
EOF

  commit_message = "[Scaffoldly] Update ${var.stage_name}/service-urls.env"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}
