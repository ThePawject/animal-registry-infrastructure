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

# Single Resource Group for both dev and prod
resource "azurerm_resource_group" "this" {
  name     = "rg-${var.project_name}"
  location = var.location
}

# Shared Network (for both environments)
module "network" {
  source                         = "./modules/network"
  name_prefix                    = var.project_name
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  address_space                  = var.vnet_address_space
  app_subnet_prefix              = var.app_subnet_prefix
  private_endpoint_subnet_prefix = var.private_endpoint_subnet_prefix
}

# Shared Storage Account with 2 containers (dev and prod)
module "storage" {
  source              = "./modules/storage"
  name_prefix         = var.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  container_names     = ["dev-animal-images", "animal-images"]
}

# Shared SQL Server with 2 databases (dev and prod)
module "sql" {
  source                        = "./modules/sql"
  name_prefix                   = var.project_name
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  aad_admin_login               = var.aad_admin_login
  aad_admin_object_id           = var.aad_admin_object_id
  aad_admin_tenant_id           = var.tenant_id
  sku_name                      = var.sql_sku
  database_names                = ["dev-appdb", "appdb"]
  public_network_access_enabled = false
  create_private_endpoint       = true
  private_endpoint_subnet_id    = module.network.private_endpoint_subnet_id
  private_dns_zone_id           = module.network.private_dns_zone_id
  private_dns_zone_name         = module.network.private_dns_zone_name
  backup_storage_redundancy     = "Local"

  # Grant database access to both web apps
  app_service_identities = {
    dev = {
      principal_id = module.appservice_dev.principal_id
      app_name     = module.appservice_dev.web_app_name
      database     = "dev-appdb"
    }
    prod = {
      principal_id = module.appservice_prod.principal_id
      app_name     = module.appservice_prod.web_app_name
      database     = "appdb"
    }
  }
}

# Shared App Service Plan (B1) for both dev and prod
resource "azurerm_service_plan" "this" {
  name                = "${var.project_name}-asp"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
}

# Dev Web App
module "appservice_dev" {
  source              = "./modules/appservice"
  name_prefix         = "${var.project_name}-dev"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id
  dotnet_version      = var.dotnet_version
  subnet_id           = module.network.app_subnet_id
  app_settings = {
    "BlobStorage__AccountName"   = module.storage.storage_account_name
    "BlobStorage__ContainerName" = "dev-animal-images"
    "Database__ConnectionString" = "Server=${module.sql.fully_qualified_domain_name};Database=dev-appdb;Authentication=Active Directory Default;Encrypt=True;"
  }
}

# Prod Web App
module "appservice_prod" {
  source              = "./modules/appservice"
  name_prefix         = var.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id
  dotnet_version      = var.dotnet_version
  subnet_id           = module.network.app_subnet_id
  app_settings = {
    "BlobStorage__AccountName"   = module.storage.storage_account_name
    "BlobStorage__ContainerName" = "animal-images"
    "Database__ConnectionString" = "Server=${module.sql.fully_qualified_domain_name};Database=appdb;Authentication=Active Directory Default;Encrypt=True;"
  }
}

# Grant Storage Blob Access - Dev
resource "azurerm_role_assignment" "storage_blob_dev" {
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.appservice_dev.principal_id
}

# Grant Storage Blob Access - Prod
resource "azurerm_role_assignment" "storage_blob_prod" {
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.appservice_prod.principal_id
}

# Static Web App (COMMENTED - for future use)
# module "staticweb" {
#   source              = "./modules/staticweb"
#   name_prefix         = var.project_name
#   location            = var.location
#   resource_group_name = azurerm_resource_group.this.name
#   sku_tier            = "Free"
#   sku_size            = "Free"
# }
