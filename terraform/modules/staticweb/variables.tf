variable "name_prefix" {
  description = "Prefix for static web app"
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

variable "sku_tier" {
  description = "Static Web App SKU tier"
  type        = string
  default     = "Free"
}

variable "sku_size" {
  description = "Static Web App SKU size"
  type        = string
  default     = "Free"
}
