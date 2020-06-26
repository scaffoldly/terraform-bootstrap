provider "github" {
  version      = "~> 2.8"
  token        = var.GITHUB_TOKEN
  organization = substr(var.GITHUB_REPOSITORY, 0, 10)
}
