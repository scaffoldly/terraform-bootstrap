variable repository_names {
  type = list(any)
}
variable "stage_domains" {
  type = map(any)
}
variable "serverless_apis" {
  type = map(any)
}
variable "shared_env_vars" {
  type = map(any)
}

module "repository_files" {
  count  = length(var.repository_names)
  source = "./repository-files"

  repository_name = var.repository_names[count.index]
  stage_domains   = var.stage_domains
  serverless_apis = var.serverless_apis
  shared_env_vars = var.shared_env_vars
}
