output "api_url" {
  value = "https://${module.appservice.web_app_default_hostname}"
}

output "static_web_url" {
  value = "https://${module.staticweb.static_web_app_default_hostname}"
}

output "storage_public_container_url" {
  value = module.storage.public_container_url
}

output "sql_server_fqdn" {
  value = module.sql.fully_qualified_domain_name
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}
