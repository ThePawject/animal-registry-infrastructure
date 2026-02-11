# Dev Environment Outputs
output "dev_api_url" {
  value       = "https://${module.appservice_dev.web_app_default_hostname}"
  description = "Dev API URL"
}

output "dev_database_name" {
  value       = "dev-appdb"
  description = "Dev database name"
}

output "dev_storage_container" {
  value       = "dev-animal-images"
  description = "Dev storage container name"
}

# Prod Environment Outputs
output "prod_api_url" {
  value       = "https://${module.appservice_prod.web_app_default_hostname}"
  description = "Prod API URL"
}

output "prod_database_name" {
  value       = "appdb"
  description = "Prod database name"
}

output "prod_storage_container" {
  value       = "animal-images"
  description = "Prod storage container name"
}

# Shared Resources
output "sql_server_name" {
  value       = module.sql.server_name
  description = "SQL Server name"
}

output "storage_account_name" {
  value       = module.storage.storage_account_name
  description = "Storage account name"
}

output "resource_group_name" {
  value       = azurerm_resource_group.this.name
  description = "Resource group name"
}
