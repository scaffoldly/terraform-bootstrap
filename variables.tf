variable "root_email" {}
variable "github_token" {}
variable "organization" {}

variable "stages" {
  type = map
}

variable "aws_region" {}

variable "public_websites" {
  type    = map
  default = {}
}

variable "serverless_apis" {
  type    = map
  default = {}
}
