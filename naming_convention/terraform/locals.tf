locals {
  # Naming convention components
  naming_convention = {
    for type in ["prefix", "suffix"] : type => [
      var.org,
      var.environment,
      type,
      module.azure_location.short_name
    ]
  }
}
