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
