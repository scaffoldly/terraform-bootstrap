variable "GITHUB_TOKEN" {
  type        = string
  description = "GitHub Token"
}

variable "GITHUB_REPOSITORY" {
  type        = string
  description = "This GitHub Repository"

  # TODO: Remove this
  default = "scaffoldly/bootstrap"
}
