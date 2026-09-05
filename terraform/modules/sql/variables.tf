variable "name_prefix" {
  description = "Prefix for SQL resources"
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

variable "aad_admin_login" {
  description = "Azure AD admin login name"
  type        = string
}

variable "aad_admin_object_id" {
  description = "Azure AD admin object id"
  type        = string
}

variable "aad_admin_tenant_id" {
  description = "Azure AD tenant id"
  type        = string
}

variable "sql_admin_login" {
  description = "SQL administrator login"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "SQL administrator password"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "SQL database SKU"
  type        = string
  default     = "Basic"
}

variable "database_names" {
  description = "List of database names to create"
  type        = list(string)
  default     = ["appdb"]
}

variable "app_subnet_id" {
  description = "App subnet ID for VNet firewall rule"
  type        = string
}

variable "backup_storage_redundancy" {
  description = "Backup storage redundancy type: Geo, Local, Zone, or GeoZone"
  type        = string
  default     = "Local"
}
