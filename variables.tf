variable "root_email" {
  type = string
}

variable "github_token" {
  type = string
}

variable "organization" {
  type = string
}

variable "aws_regions" {
  type = list(string)
}

variable "serverless_api_subdomain" {
  type    = string
  default = "sly"
}

variable "stages" {
  type = map(
    object({
      domain           = string
      subdomain_suffix = string
    })
  )
}

# TODO: Env Vars
variable "public_websites" {
  type = map(
    object({
      template  = string
      repo_name = string
    })
  )
  default = {}
}

# TODO: Env Vars
variable "serverless_apis" {
  type = map(
    object({
      template  = string
      repo_name = string
    })
  )
  default = {}
}

variable "shared_env_vars" {
  type    = map(string)
  default = {}
}
