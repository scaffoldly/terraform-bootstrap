variable "name" {
  type = string
}

resource "random_string" "random" {
  length  = 4
  special = false
}

resource "aws_organizations_account" "account" {
  name  = "${var.name}-${random_string.random.result}"
  email = "aws+${var.name}-${random_string.random.result}@cnuss.com"
}
