variable "naming_prefix" {
  description = "Prefix to use for naming resources (list of strings)"
  type        = list(string)
  default     = null
}

variable "naming_suffix" {
  description = "Suffix to use for naming resources (list of strings)"
  type        = list(string)
  default     = null
}

variable "location" {
  description = "Azure region where the storage account will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account"
  type        = string
  default     = "LRS"
}

variable "subnet_id" {
  description = "ID of the subnet where private endpoints will be created"
  type        = string
}

variable "private_endpoints" {
  description = "List of private endpoint types to create (blob, file, table, queue, dfs)"
  type        = list(string)
  default     = []
}

variable "private_dns_zone_ids" {
  description = "Map of private DNS zone IDs for each endpoint type"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
