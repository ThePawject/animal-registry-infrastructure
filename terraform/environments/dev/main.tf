terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

locals {
  name_prefix = "${var.project_name}-dev"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_prefix}"
  location = var.location
}

module "storage" {
  source              = "../../modules/storage"
  name_prefix         = "${var.project_name}dev"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  public_container_name = var.public_container_name
}

module "appservice" {
  source              = "../../modules/appservice"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = var.app_service_sku
  dotnet_version      = var.dotnet_version
  app_settings = {
    "Storage__AccountName"   = module.storage.storage_account_name
    "Storage__ContainerName" = module.storage.public_container_name
    "Sql__Server"            = module.sql.fully_qualified_domain_name
    "Sql__Database"          = module.sql.database_name
  }
}

module "sql" {
  source                         = "../../modules/sql"
  name_prefix                    = local.name_prefix
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  aad_admin_login                = var.aad_admin_login
  aad_admin_object_id            = var.aad_admin_object_id
  aad_admin_tenant_id            = var.tenant_id
  sku_name                       = var.sql_sku
  public_network_access_enabled  = true
  create_private_endpoint        = false
  database_name                  = var.sql_database_name
}

module "staticweb" {
  source              = "../../modules/staticweb"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku_tier            = "Free"
  sku_size            = "Free"
}

resource "azurerm_role_assignment" "storage_blob" {
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.appservice.principal_id
}
