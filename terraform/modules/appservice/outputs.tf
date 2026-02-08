output "web_app_name" {
  value = azurerm_linux_web_app.this.name
}

output "web_app_id" {
  value = azurerm_linux_web_app.this.id
}

output "web_app_default_hostname" {
  value = azurerm_linux_web_app.this.default_hostname
}

output "principal_id" {
  value = azurerm_linux_web_app.this.identity[0].principal_id
}
