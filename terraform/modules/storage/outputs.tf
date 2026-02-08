output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "public_container_name" {
  value = azurerm_storage_container.public.name
}

output "public_container_url" {
  value = "${azurerm_storage_account.this.primary_blob_endpoint}${azurerm_storage_container.public.name}"
}

