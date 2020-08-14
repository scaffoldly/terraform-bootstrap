variable "name" {
  type = string
}

resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_organizations_account" "account" {
  name      = "${var.name}-${random_string.random.result}"
  email     = "aws+${var.name}-${random_string.random.result}@cnuss.com" # TODO: Allow email address to be specified
  role_name = "BootstrapAccessRole"
}

output "account_id" {
  value = aws_organizations_account.account.id
}

output "account_name" {
  value = aws_organizations_account.account.name
}
