provider "github" {
  version      = "~> 2.8"
  token        = var.BOOTSTRAP_GITHUB_TOKEN
  organization = split("/", split(":", data.external.git.result.repo)[1])[0]
}

provider "external" {
  version = "~> 1.2"
}
