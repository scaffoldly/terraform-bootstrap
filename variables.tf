variable "root_email" {}
variable "github_token" {}
variable "organization" {}

variable "aws_region" {}
variable "serverless_api_subdomain" {}

variable "stages" {
  type = map(any)
}

variable "public_websites" {
  type    = map(any)
  default = {}
}

variable "serverless_apis" {
  type    = map(any)
  default = {}
}

variable "shared_env_vars" {
  type    = map(any)
  default = {}
}
