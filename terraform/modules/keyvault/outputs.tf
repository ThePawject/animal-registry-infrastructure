output "key_vault_id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.this.id
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.this.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.this.vault_uri
}

output "sql_password_secret_id" {
  description = "SQL password secret ID (for Key Vault references)"
  value       = azurerm_key_vault_secret.sql_password.id
}

output "sql_password_name" {
  description = "SQL password secret name"
  value       = azurerm_key_vault_secret.sql_password.name
}
