variable "name_prefix" {
  description = "Prefix for Application Insights resources"
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

variable "daily_data_cap_gb" {
  description = "Daily ingestion cap in GB"
  type        = number
  default     = 0.15
}
