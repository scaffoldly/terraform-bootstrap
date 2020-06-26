variable "GITHUB_TOKEN" {
  type        = string
  description = "GitHub Token"

  # TODO: Remove this
  default = "b06c7d38c4b388d2e431ee270a42260f1c72d7b7"
}

variable "GITHUB_REPOSITORY" {
  type        = string
  description = "This GitHub Repository"

  # TODO: Remove this
  default = "scaffoldly/bootstrap"
}
