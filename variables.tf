variable "root_email" {}
variable "github_token" {}
variable "organization" {}

variable "stages" {
  type = list
}
variable "nonlive" {
  type = map
}
variable "live" {
  type = map
}

variable "aws_region" {}
variable "api_subdomain" {}
variable "serverless_apis" {
  type = map
}
