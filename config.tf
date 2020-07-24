locals {
  organization = substr(data.external.git.result.repo, 0, 4) == "http" ? split("/", data.external.git.result.repo)[3] : split("/", split(":", data.external.git.result.repo)[1])[0]
}

provider "github" {
  version      = "~> 2.8"
  token        = var.BOOTSTRAP_GITHUB_TOKEN
  organization = local.organization
}

provider "external" {
  version = "~> 1.2"
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = local.organization

    workspaces {
      name = "bootstrap"
    }
  }
}

credentials "app.terraform.io" {
  token = var.BOOTSTRAP_TERRAFORM_TOKEN
}
