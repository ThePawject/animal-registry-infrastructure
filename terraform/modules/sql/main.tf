resource "azurerm_mssql_server" "this" {
  name                          = "${var.name_prefix}-sql"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.public_network_access_enabled

  azuread_administrator {
    login_username              = var.aad_admin_login
    object_id                   = var.aad_admin_object_id
    tenant_id                   = var.aad_admin_tenant_id
    azuread_authentication_only = true
  }
}

resource "azurerm_mssql_database" "databases" {
  for_each             = toset(var.database_names)
  name                 = each.value
  server_id            = azurerm_mssql_server.this.id
  sku_name             = var.sku_name
  storage_account_type = var.backup_storage_redundancy
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

# Grant App Service managed identities database access
resource "null_resource" "grant_app_service_db_access" {
  for_each = var.app_service_identities

  triggers = {
    principal_id = each.value.principal_id
    app_name     = each.value.app_name
    database     = each.value.database
    server_name  = azurerm_mssql_server.this.name
  }

  provisioner "local-exec" {
    command = <<-EOT
      az sql db query \
        --server ${azurerm_mssql_server.this.name} \
        --database ${each.value.database} \
        --resource-group ${var.resource_group_name} \
        --auth-mode ActiveDirectoryIntegrated \
        --query-text "IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = '${each.value.app_name}') BEGIN CREATE USER [${each.value.app_name}] FROM EXTERNAL PROVIDER; ALTER ROLE db_datareader ADD MEMBER [${each.value.app_name}]; ALTER ROLE db_datawriter ADD MEMBER [${each.value.app_name}]; ALTER ROLE db_ddladmin ADD MEMBER [${each.value.app_name}]; END"
    EOT
  }

  depends_on = [
    azurerm_mssql_database.databases
  ]
}
