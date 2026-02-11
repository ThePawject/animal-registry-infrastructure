resource "azurerm_service_plan" "this" {
  count               = var.create_service_plan ? 1 : 0
  name                = "${var.name_prefix}-asp"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
}

resource "azurerm_linux_web_app" "this" {
  name                = "${var.name_prefix}-api"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id != null ? var.service_plan_id : azurerm_service_plan.this[0].id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      dotnet_version = var.dotnet_version
    }

    cors {
      allowed_origins = [
        "http://localhost:3000",
        "https://thepawject.github.io",
      ]
      support_credentials = true
    }
  }

  app_settings              = var.app_settings
  virtual_network_subnet_id = var.subnet_id
}
