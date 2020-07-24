terraform {
  required_version = ">= 0.12"
  backend "remote" {}
}

provider "github" {
  version      = "~> 2.8"
  token        = var.BOOTSTRAP_GITHUB_TOKEN
  organization = data.external.git.result.organization
}

provider "external" {
  version = "~> 1.2"
}
