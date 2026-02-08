variable "name_prefix" {
  description = "Prefix for network resources"
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

variable "address_space" {
  description = "VNet address space"
  type        = list(string)
}

variable "app_subnet_prefix" {
  description = "Subnet prefix for App Service integration"
  type        = string
}

variable "private_endpoint_subnet_prefix" {
  description = "Subnet prefix for private endpoints"
  type        = string
}
