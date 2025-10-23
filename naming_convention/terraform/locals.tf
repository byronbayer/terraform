locals {
  # Naming convention components
  naming_convention_postfix = [var.org, var.environment, "postfix", module.azure_location.short_name]
  naming_convention_prefix  = ["prefix", var.environment, module.azure_location.short_name]
}
