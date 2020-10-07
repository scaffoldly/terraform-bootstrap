variable "root_email" {}
variable "github_token" {}
variable "organization" {}
variable "stages" {
  type = "map"
}
variable "api_subdomain" {}
variable "serverless_apis" {
  type = "map"
}