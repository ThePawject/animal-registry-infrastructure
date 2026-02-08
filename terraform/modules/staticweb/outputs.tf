output "static_web_app_name" {
  value = azurerm_static_web_app.this.name
}

output "static_web_app_default_hostname" {
  value = azurerm_static_web_app.this.default_host_name
}
