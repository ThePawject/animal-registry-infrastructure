data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                       = "${var.name_prefix}-kv"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  lifecycle {
    ignore_changes = [
      tenant_id,
    ]
  }
}

resource "azurerm_role_assignment" "admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id

  lifecycle {
    ignore_changes = [
      principal_id,
    ]
  }
}

resource "azurerm_role_assignment" "app_secrets_user" {
  for_each             = var.app_service_principal_ids
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}

resource "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-password"
  value        = var.sql_password
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_role_assignment.admin
  ]
}

resource "azurerm_key_vault_secret" "dev_database_connection" {
  name         = "dev-database-connection-string"
  value        = var.dev_database_connection_string
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_role_assignment.admin
  ]
}

resource "azurerm_key_vault_secret" "prod_database_connection" {
  name         = "prod-database-connection-string"
  value        = var.prod_database_connection_string
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_role_assignment.admin
  ]
}
