resource "azurerm_mssql_server" "this" {
  name                         = "${var.name_prefix}-sql"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  minimum_tls_version          = "1.2"
  public_network_access_enabled = var.public_network_access_enabled

  azuread_administrator {
    login_username               = var.aad_admin_login
    object_id                    = var.aad_admin_object_id
    tenant_id                    = var.aad_admin_tenant_id
    azuread_authentication_only  = true
  }
}

resource "azurerm_mssql_database" "this" {
  name      = var.database_name
  server_id = azurerm_mssql_server.this.id
  sku_name  = var.sku_name
}

resource "azurerm_private_endpoint" "sql" {
  count               = var.create_private_endpoint ? 1 : 0
  name                = "${var.name_prefix}-sql-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name_prefix}-sql-psc"
    private_connection_resource_id = azurerm_mssql_server.this.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_a_record" "sql" {
  count               = var.create_private_endpoint ? 1 : 0
  name                = azurerm_mssql_server.this.name
  zone_name           = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql[0].private_service_connection[0].private_ip_address]
}
