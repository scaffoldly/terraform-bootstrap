terraform {
  required_version = ">= 0.14"
  experiments      = [module_variable_optional_attrs]

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.33.0"
    }

    dnsimple = {
      source  = "dnsimple/dnsimple"
      version = "0.5.1"
    }

    external = {
      source  = "hashicorp/external"
      version = "2.1.0"
    }

    github = {
      source  = "integrations/github"
      version = "4.6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.7.0"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "aws" {
  alias  = "root"
  region = var.aws_regions[0]
}

provider "aws" {
  region = var.aws_regions[0] # TODO Create this provider in each module with region for_each

  assume_role {
    role_arn = "arn:aws:iam::${module.aws_organization.account_id}:role/ScaffoldlyBootstrap"
  }
}

provider "github" {
  token = var.github_token
  owner = var.organization
}
