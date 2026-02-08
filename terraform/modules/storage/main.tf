resource "azurerm_storage_account" "this" {
  name                     = "${var.name_prefix}st"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = true
}

resource "azurerm_storage_container" "public" {
  name                  = var.public_container_name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "blob"
}

