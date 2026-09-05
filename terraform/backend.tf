terraform {
  backend "azurerm" {
    resource_group_name  = "rg-thepawject-tfstate"
    storage_account_name = "thepawjecttfstate"
    container_name       = "tfstate"
    key                  = "thepawject.tfstate"
    use_azuread_auth     = true
  }
}
