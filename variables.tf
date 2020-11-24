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

variable "additional_env_vars" {
  type    = map
  default = {}
}
