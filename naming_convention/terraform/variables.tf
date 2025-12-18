variable "location" {
  description = "The Azure location to deploy resources"
  default     = "UK South"
}
variable "org" {
  description = "The organization name"
  default     = "myorg"
}
variable "environment" {
  description = "The environment name (e.g., dev, prod)"
  default     = "dev"
}

variable "instance" {
  description = "Environment instance identifier (01, 02, etc.)"
  type        = string
  default     = "01"
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}
