output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "container_names" {
  value       = [for c in azurerm_storage_container.containers : c.name]
  description = "List of created container names"
}

output "containers" {
  value = {
    for name, container in azurerm_storage_container.containers :
    name => {
      name = container.name
      url  = "${azurerm_storage_account.this.primary_blob_endpoint}${container.name}"
    }
  }
  description = "Map of container details"
}

