resource "azurerm_mssql_server" "this" {
  name                          = "${var.name_prefix}-sql"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true

  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password

  # Keep Azure AD admin for your management access
  azuread_administrator {
    login_username              = var.aad_admin_login
    object_id                   = var.aad_admin_object_id
    tenant_id                   = var.aad_admin_tenant_id
    azuread_authentication_only = false # Allow both SQL and Azure AD
  }
}

resource "azurerm_mssql_database" "databases" {
  for_each             = toset(var.database_names)
  name                 = each.value
  server_id            = azurerm_mssql_server.this.id
  sku_name             = var.sku_name
  storage_account_type = var.backup_storage_redundancy
}

resource "azurerm_mssql_virtual_network_rule" "app_subnet" {
  name      = "${var.name_prefix}-sql-vnet-rule"
  server_id = azurerm_mssql_server.this.id
  subnet_id = var.app_subnet_id

  ignore_missing_vnet_service_endpoint = false

  depends_on = [
    azurerm_mssql_database.databases
  ]
}
