provider "github" {
  version      = "~> 2.8"
  token        = var.github_token
  organization = var.organization
}

provider "external" {
  version = "~> 1.2"
}

provider "random" {
  version = "2.3.0"
}

provider "aws" {
  version = "~> 3.0.0"
  region  = var.aws_region
}

provider "aws" {
  alias   = "org"
  version = "~> 3.0.0"
  region  = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${module.aws_organization.account_id}:role/BootstrapAccessRole"
  }
}

