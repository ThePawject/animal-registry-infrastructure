variable "name_prefix" {
  description = "Prefix for App Service resources"
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

variable "sku_name" {
  description = "App Service plan SKU"
  type        = string
  default     = "B1"
}

variable "dotnet_version" {
  description = ".NET version"
  type        = string
  default     = "9.0"
}

variable "app_settings" {
  description = "App settings for web app"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "Subnet id for VNet integration"
  type        = string
  default     = null
}
