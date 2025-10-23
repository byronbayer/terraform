variable "naming_prefix" {
  description = "Prefix for naming the private endpoint (typically the parent resource name)"
  type        = list(string)
  default     = null
}

variable "naming_suffix" {
  description = "Optional suffix for naming the private endpoint"
  type        = list(string)
  default     = null
}

variable "location" {
  description = "Azure region where the private endpoint will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the private endpoint will be created"
  type        = string
}

variable "private_connection_resource_id" {
  description = "The ID of the resource to connect to via private endpoint"
  type        = string
}

variable "subresource_names" {
  description = "List of subresource names which the Private Endpoint is able to connect to (e.g., ['blob'], ['vault'])"
  type        = list(string)
}

variable "is_manual_connection" {
  description = "Does the Private Endpoint require manual approval from the remote resource owner?"
  type        = bool
  default     = false
}

variable "dns_zone_group_name" {
  description = "Name of the Private DNS Zone Group"
  type        = string
}

variable "dns_zone_ids" {
  description = "List of Private DNS Zone IDs to associate with the private endpoint"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the private endpoint"
  type        = map(string)
  default     = {}
}
