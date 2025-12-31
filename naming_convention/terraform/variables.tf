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
  description = "The environment name (e.g., dev, tst, uat, prd)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "tst", "uat", "prd"], var.environment)
    error_message = "Environment must be one of: dev, tst, uat, prd."
  }
}

variable "instance" {
  description = "Environment instance identifier (01, 02, etc.)"
  type        = string
  default     = "01"

  validation {
    condition     = can(regex("^[0-9]{2}$", var.instance))
    error_message = "Instance must be a two-digit number (e.g., 01, 02, 10)."
  }
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id))
    error_message = "Subscription ID must be a valid GUID format."
  }
}
