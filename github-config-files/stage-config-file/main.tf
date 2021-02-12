variable "repository" {}
variable "branch" {}
variable "service_name" {}
variable "stage_config" {
  type = map(any)
}

locals {
  scrubbed_service_name = replace(var.service_name, "-", "_")
}

resource "github_repository_file" "services" {
  for_each = var.stage_config

  repository = var.repository
  branch     = var.branch
  file       = ".scaffoldly/.env/${each.key}/${var.service_name}.env"

  content = <<EOF
  ${upper(local.scrubbed_service_name)}_${upper(each.key)}_URL=${lookup(each.value, "url", "")}
  EOF

  commit_message = "[Scaffoldly] Update env: ${var.service_name} ${each.key}"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}
