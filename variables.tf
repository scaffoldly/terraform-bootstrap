variable "root_email" {}
variable "github_token" {}
variable "organization" {}

variable "aws_region" {}
variable "serverless_api_subdomain" {}

variable "stages" {
  type = map
}

variable "public_websites" {
  type    = map
  default = {}
}

variable "serverless_apis" {
  type    = map
  default = {}
}

locals {
  aws_region = "us-east-1"

  serverless_api_subdomain = "sls"

  stages = {
    nonlive = {
      domain           = "texts.email"
      subdomain_suffix = "dev"
    }

    live = {
      domain           = "texts.email"
      subdomain_suffix = ""
    }
  }

  public_websites = {
    media = {}
  }

  serverless_apis = {
    email   = {}
    text    = {}
    account = {}
  }
}