resource "github_repository" "repository" {
  name = "${var.prefix}-${var.service_name}-${var.suffix}"

  private       = true
  has_downloads = false
  has_issues    = false
  has_projects  = false
  has_wiki      = false

  template {
    owner      = "scaffoldly"
    repository = var.template_repo
  }
}
