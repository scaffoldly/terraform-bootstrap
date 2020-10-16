output "main_nameservers" {
  value = module.dns.nameservers
}

output "serverless_apis___screate_these_dns_records" {
  for_each = module.dns.stage_domains

  stage       = each.key
  domain      = each.value.domain
  record_type = "NS"
  records     = each.value.nameservers
}
