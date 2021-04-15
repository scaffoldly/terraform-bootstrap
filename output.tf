output "account_id" {
  value = module.aws_organization.account_id
}

output "stage_domains" {
  value = module.dns.stage_domains
}
