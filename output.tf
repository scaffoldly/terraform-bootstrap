output "main_nameservers" {
  value = module.dns.nameservers
}

output "create_these_dns_records" {
  for_each = module.dns.stage_domains

  stage       = each.key
  domain      = each.value.domain
  record_type = "NS"
  records     = each.value.nameservers
}
