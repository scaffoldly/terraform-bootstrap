variable "prefix" {}
variable "service_name" {}
variable "suffix" {}
variable "template_repo" {}


resource "github_repository" "repository" {
  name = "${var.prefix}-${var.service_name}-${var.suffix}"

  private                = true
  has_downloads          = false
  has_issues             = false
  has_projects           = false
  has_wiki               = false
  delete_branch_on_merge = true

  default_branch = "master"

  template {
    owner      = "scaffoldly"
    repository = var.template_repo
  }
}
