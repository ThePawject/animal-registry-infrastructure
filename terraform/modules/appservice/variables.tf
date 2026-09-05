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

variable "always_on" {
  description = "Whether to enable Always On for the web app"
  type        = bool
  default     = true
}

variable "sku_name" {
  description = "App Service plan SKU"
  type        = string
  default     = "B1"
}

variable "service_plan_id" {
  description = "Existing App Service Plan ID (if not creating new plan)"
  type        = string
  default     = null
}

variable "create_service_plan" {
  description = "Whether to create a new service plan"
  type        = bool
  default     = false
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

variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = []
}

variable "cors_support_credentials" {
  description = "Whether CORS should support credentials"
  type        = bool
  default     = false
}
