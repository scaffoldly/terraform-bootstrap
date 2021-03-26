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
  type    = list(string)
  default = ["us-east-1"]
}

variable "dns_provider" {
  type    = string
  default = "aws"
}

variable "serverless_api_subdomain" {
  type    = string
  default = "sly"
}

variable "stages" {
  type = map(
    object({
      domain           = string
      subdomain_suffix = optional(string)
    })
  )
}

# TODO: Env Vars
variable "public_websites" {
  type = map(
    object({
      template  = string
      repo_name = optional(string)
    })
  )
  default = {}
}

variable "enable_account_service" {
  type    = bool
  default = true
}

# TODO: Env Vars
variable "serverless_apis" {
  type = map(
    object({
      template  = string
      repo_name = optional(string)
    })
  )
  default = {}
}

variable "shared_env_vars" {
  type    = map(string)
  default = {}
}
