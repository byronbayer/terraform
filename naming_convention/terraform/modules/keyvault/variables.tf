variable "naming_prefix" {
  description = "Prefix components for the naming module (e.g., [org, environment, app_name, location])"
  type        = list(string)
  default     = null
}

variable "naming_suffix" {
  description = "Suffix components for the naming module (e.g., [org, environment, app_name, location])"
  type        = list(string)
  default     = null
}

variable "purpose" {
  description = "Purpose identifier for the resource (e.g., secrets, certs, keys)"
  type        = string
  default     = "gen"
}

variable "location" {
  description = "The Azure location for the Key Vault"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "tenant_id" {
  description = "The Azure AD tenant ID"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID for the private endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "The private DNS zone ID for Key Vault"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "purge_protection_enabled" {
  description = "Whether purge protection is enabled for the Key Vault. When enabled, the Key Vault and its objects cannot be purged during the retention period."
  type        = bool
  default     = true
}
