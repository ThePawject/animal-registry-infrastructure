variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "thepawject"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "polandcentral"
}

variable "subscription_id" {
  description = "Azure subscription id"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant id"
  type        = string
}

variable "aad_admin_login" {
  description = "Azure AD admin login"
  type        = string
}

variable "aad_admin_object_id" {
  description = "Azure AD admin object id"
  type        = string
}

variable "app_service_sku" {
  description = "App Service Plan SKU"
  type        = string
  default     = "B1"
}

variable "dotnet_version" {
  description = ".NET version"
  type        = string
  default     = "9.0"
}

variable "sql_sku" {
  description = "SQL database SKU"
  type        = string
  default     = "Basic"
}

variable "vnet_address_space" {
  description = "VNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "app_subnet_prefix" {
  description = "App subnet prefix"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_endpoint_subnet_prefix" {
  description = "Private endpoint subnet prefix"
  type        = string
  default     = "10.0.2.0/24"
}

variable "dev_static_web_custom_domains" {
  description = "Custom domains for dev static web app"
  type        = list(string)
  default     = ["dev.mojeschronisko.pl"]
}

variable "prod_static_web_custom_domains" {
  description = "Custom domains for prod static web app"
  type        = list(string)
  default     = ["www.mojeschronisko.pl"]
}
