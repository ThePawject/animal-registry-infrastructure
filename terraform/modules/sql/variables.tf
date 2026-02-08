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

variable "sku_name" {
  description = "SQL database SKU"
  type        = string
  default     = "Basic"
}

variable "create_private_endpoint" {
  description = "Whether to create private endpoint"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet id for private endpoint"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS zone id"
  type        = string
  default     = null
}

variable "private_dns_zone_name" {
  description = "Private DNS zone name"
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}
