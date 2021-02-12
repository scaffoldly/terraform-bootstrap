variable "repository" {}
variable "branch" {}
variable "stage_config" {
  type = map(any)
}

resource "github_repository_file" "services" {
  for_each = var.stage_config

  repository = var.repository
  branch     = var.branch
  file       = ".scaffoldly/.env/${each.key}/${lookup(each.value, "repo_name", "unknown")}.env"

  content = <<EOF
  ${replace(upper(lookup(each.value, "repo_name", "unknown")), "-", "_")}_${upper(each.key)}_URL=${lookup(each.value, "url", "")}
  EOF

  commit_message = "[Scaffoldly] Update env: ${lookup(each.value, "repo_name", "unknown")} (${each.key} API URL)"
  commit_author  = "Scaffoldly Bootstrap"
  commit_email   = "bootstrap@scaffold.ly"
}
