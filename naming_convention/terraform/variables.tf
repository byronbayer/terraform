variable "location" {
  description = "The Azure location to deploy resources"
  type        = string
  default     = "UK South"
}

variable "org" {
  description = "The organization name"
  type        = string
  default     = "myorg"
}

variable "environment" {
  description = "The environment name — must be exactly 3 characters (e.g. dev, tst, prd)"
  type        = string
  default     = "dev"
  validation {
    condition     = length(var.environment) == 3 && can(regex("^[a-z]{3}$", var.environment))
    error_message = "environment must be exactly 3 characters long (e.g. dev, tst, prd) and contain only lowercase letters."
  }
}

variable "subscription_id" {
  description = "The Azure subscription ID where resources will be deployed"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space CIDR blocks for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "private_endpoint_subnet_prefix" {
  description = "Address prefix for the private endpoints subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}
