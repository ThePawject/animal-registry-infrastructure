variable "name_prefix" {
  description = "Prefix for storage resources"
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

variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Storage account replication"
  type        = string
  default     = "LRS"
}

variable "container_names" {
  description = "List of container names to create"
  type        = list(string)
  default     = ["images"]
}

