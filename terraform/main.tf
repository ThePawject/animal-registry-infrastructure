terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

locals {
  key_vault_name = "${var.project_name}-kv"
}

# Single Resource Group for both dev and prod
resource "azurerm_resource_group" "this" {
  name     = "rg-${var.project_name}"
  location = var.location
}

resource "random_password" "sql_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

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

# App Service Plan
resource "azurerm_service_plan" "this" {
  name                = "${var.project_name}-asp"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
}

resource "azurerm_service_plan" "dev" {
  name                = "${var.project_name}-free-asp"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "F1"
}

# Shared Application Insights for both dev and prod
module "appinsights" {
  source              = "./modules/appinsights"
  name_prefix         = var.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
}

# Dev Web App
module "appservice_dev" {
  source              = "./modules/appservice"
  name_prefix         = "${var.project_name}-dev"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.dev.id
  always_on           = false
  dotnet_version      = var.dotnet_version
  # subnet_id           = module.network.app_subnet_id
  cors_allowed_origins = [
    "http://localhost:3000",
    "https://dev.mojeschronisko.pl",
  ]
  cors_support_credentials = true
  app_settings = {
    "BlobStorage__AccountName"                   = module.storage.storage_account_name
    "BlobStorage__ContainerName"                 = "dev-animal-images"
    "Database__ConnectionString"                 = "@Microsoft.KeyVault(SecretUri=https://${local.key_vault_name}.vault.azure.net/secrets/dev-database-connection-string/)"
    "ApplicationInsights__ConnectionString"      = module.appinsights.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "APPINSIGHTS_CLOUDROLE"                      = "dev-api"
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
  cors_allowed_origins = [
    "https://www.mojeschronisko.pl",
  ]
  cors_support_credentials = true
  app_settings = {
    "BlobStorage__AccountName"                   = module.storage.storage_account_name
    "BlobStorage__ContainerName"                 = "animal-images"
    "Database__ConnectionString"                 = "@Microsoft.KeyVault(SecretUri=https://${local.key_vault_name}.vault.azure.net/secrets/prod-database-connection-string/)"
    "ApplicationInsights__ConnectionString"      = module.appinsights.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "APPINSIGHTS_CLOUDROLE"                      = "prod-api"
  }
}

# Dev Static Web App
module "staticweb_dev" {
  source              = "./modules/staticweb"
  name_prefix         = "${var.project_name}-dev"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.this.name
  sku_tier            = "Free"
  sku_size            = "Free"
  custom_domains      = var.dev_static_web_custom_domains
}

# Prod Static Web App
module "staticweb_prod" {
  source              = "./modules/staticweb"
  name_prefix         = var.project_name
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.this.name
  sku_tier            = "Free"
  sku_size            = "Free"
  custom_domains      = var.prod_static_web_custom_domains
}

module "keyvault" {
  source              = "./modules/keyvault"
  name_prefix         = var.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sql_password        = random_password.sql_password.result

  dev_database_connection_string = "Server=${module.sql.fully_qualified_domain_name};Database=dev-appdb;User ID=${module.sql.sql_admin_login};Password=${random_password.sql_password.result};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

  prod_database_connection_string = "Server=${module.sql.fully_qualified_domain_name};Database=appdb;User ID=${module.sql.sql_admin_login};Password=${random_password.sql_password.result};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

  app_service_principal_ids = {
    dev  = module.appservice_dev.principal_id
    prod = module.appservice_prod.principal_id
  }

  depends_on = [
    module.appservice_dev,
    module.appservice_prod
  ]
}

# Shared SQL Server with 2 databases (dev and prod)
module "sql" {
  source                    = "./modules/sql"
  name_prefix               = var.project_name
  location                  = var.location
  resource_group_name       = azurerm_resource_group.this.name
  aad_admin_login           = var.aad_admin_login
  aad_admin_object_id       = var.aad_admin_object_id
  aad_admin_tenant_id       = var.tenant_id
  sql_admin_login           = "sqladmin"
  sql_admin_password        = random_password.sql_password.result
  sku_name                  = var.sql_sku
  database_names            = ["dev-appdb", "appdb"]
  app_subnet_id             = module.network.app_subnet_id
  backup_storage_redundancy = "Zone"

  depends_on = [
    module.network
  ]
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
