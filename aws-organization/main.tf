variable "name" {
  type = string
}

resource "random_string" "random" {
  length  = 5
  special = false
}

resource "aws_organizations_account" "account" {
  name      = "${var.name}-${random_string.random.result}"
  email     = "aws+${var.name}-${random_string.random.result}@cnuss.com" # TODO: Allow email address to be specified
  role_name = "BootstrapAccessRole"
}

output "account_id" {
  value = "${aws_organizations_account.account.id}"
}
