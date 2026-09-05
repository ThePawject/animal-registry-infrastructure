# Log Analytics Workspace (required for Application Insights)
resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 90 # Free tier limit
}

# Application Insights
resource "azurerm_application_insights" "this" {
  name                = "${var.name_prefix}-ai"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"

  # Hard cap at 5GB/day to stay within free tier and prevent any charges
  daily_data_cap_in_gb                  = 5
  daily_data_cap_notifications_disabled = false
}
