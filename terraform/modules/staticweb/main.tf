resource "azurerm_static_web_app" "this" {
  name                = "${var.name_prefix}-swa"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier            = var.sku_tier
  sku_size            = var.sku_size
}

resource "azurerm_static_web_app_custom_domain" "this" {
  for_each          = toset(var.custom_domains)
  static_web_app_id = azurerm_static_web_app.this.id
  domain_name       = each.value
  validation_type   = "cname-delegation"
}
