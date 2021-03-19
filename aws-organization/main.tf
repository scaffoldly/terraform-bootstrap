terraform {
  required_version = ">= 0.14"
}

variable "name" {
  type = string
}

variable "email" {
  type = string
}

locals {
  name = lower(var.name)
}

resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_organizations_account" "account" {
  name      = "${local.name}-${random_string.random.result}"
  email     = var.email
  role_name = "BootstrapAccessRole"
}

# Used to give AWS time to provision the new account
resource "time_sleep" "wait_120_seconds" {
  create_duration = "120s"

  depends_on = [
    aws_organizations_account.account
  ]
}

output "slept_time" {
  value = time_sleep.wait_120_seconds.id
}

output "account_id" {
  value = aws_organizations_account.account.id
}

output "account_name" {
  value = aws_organizations_account.account.name
}
