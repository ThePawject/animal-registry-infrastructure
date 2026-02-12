output "sql_server_name" {
  description = "SQL Server name"
  value       = module.sql.server_name
}

output "sql_server_fqdn" {
  description = "SQL Server fully qualified domain name"
  value       = module.sql.fully_qualified_domain_name
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = module.keyvault.key_vault_name
}

output "sql_admin_login" {
  description = "SQL admin login username"
  value       = "sqladmin"
}

output "connection_string_format_dev" {
  description = "Connection string format for dev (use in App Service settings)"
  value       = "Server=${module.sql.fully_qualified_domain_name};Database=dev-appdb;User ID=sqladmin;Password=@Microsoft.KeyVault(VaultName=${module.keyvault.key_vault_name};SecretName=sql-password);Encrypt=True;"
}

output "connection_string_format_prod" {
  description = "Connection string format for prod (use in App Service settings)"
  value       = "Server=${module.sql.fully_qualified_domain_name};Database=appdb;User ID=sqladmin;Password=@Microsoft.KeyVault(VaultName=${module.keyvault.key_vault_name};SecretName=sql-password);Encrypt=True;"
}

output "dev_webapp_name" {
  description = "Dev web app name"
  value       = module.appservice_dev.web_app_name
}

output "prod_webapp_name" {
  description = "Prod web app name"
  value       = module.appservice_prod.web_app_name
}

# Dev Static Web App
output "dev_static_web_app_name" {
  description = "Dev static web app name"
  value       = module.staticweb_dev.static_web_app_name
}

output "dev_static_web_app_url" {
  description = "Dev static web app default URL"
  value       = "https://${module.staticweb_dev.static_web_app_default_hostname}"
}

output "dev_static_web_app_custom_domains" {
  description = "Dev static web app custom domains validation info"
  value       = module.staticweb_dev.custom_domain_validation_tokens
  sensitive   = true
}

# Prod Static Web App
output "prod_static_web_app_name" {
  description = "Prod static web app name"
  value       = module.staticweb_prod.static_web_app_name
}

output "prod_static_web_app_url" {
  description = "Prod static web app default URL"
  value       = "https://${module.staticweb_prod.static_web_app_default_hostname}"
}

output "prod_static_web_app_custom_domains" {
  description = "Prod static web app custom domains validation info"
  value       = module.staticweb_prod.custom_domain_validation_tokens
  sensitive   = true
}
