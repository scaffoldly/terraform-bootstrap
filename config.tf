terraform {
  required_version = ">= 0.12"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "scaffoldly"
    workspaces {
      name = "bootstrap"
    }
  }
}

provider "github" {
  version      = "~> 2.8"
  token        = var.BOOTSTRAP_GITHUB_TOKEN
  organization = data.external.git.result.organization
}

provider "external" {
  version = "~> 1.2"
}
