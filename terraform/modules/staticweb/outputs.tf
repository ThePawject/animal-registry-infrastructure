output "static_web_app_name" {
  value = azurerm_static_web_app.this.name
}

output "static_web_app_default_hostname" {
  value = azurerm_static_web_app.this.default_host_name
}

output "static_web_app_id" {
  value = azurerm_static_web_app.this.id
}

output "custom_domain_validation_tokens" {
  description = "Validation tokens for custom domains"
  value = {
    for domain, config in azurerm_static_web_app_custom_domain.this :
    domain => config.validation_token
  }
}
