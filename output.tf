output "main_nameservers" {
  value = module.dns.nameservers
}

output "serverless_apis_create_these_dns_records" {
  value = {
    for stage in module.dns.stage_domains :
    records => {
      domain      = stage.domain
      record_type = "NS"
      records     = stage.nameservers
    }
  }
}
