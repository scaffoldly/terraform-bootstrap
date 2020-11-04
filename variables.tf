variable "root_email" {}
variable "github_token" {}
variable "organization" {}

variable "stages" {
  type = map
}

variable "aws_region" {}

variable "static_websites" {
  type = map
}

variable "serverless_apis" {
  type = map
}
