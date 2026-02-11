variable "name_prefix" {
  description = "Prefix for Key Vault name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "sql_password" {
  description = "SQL password to store"
  type        = string
  sensitive   = true
}

variable "app_service_principal_ids" {
  description = "Map of app service principal IDs that need access"
  type        = map(string)
  default     = {}
}

variable "dev_database_connection_string" {
  type        = string
  description = "Complete database connection string for dev environment"
  sensitive   = true
}

variable "prod_database_connection_string" {
  type        = string
  description = "Complete database connection string for prod environment"
  sensitive   = true
}
