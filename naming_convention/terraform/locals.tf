locals {
  # Naming convention components
  naming_convention = {
    for type in ["prefix", "suffix"] : type => [
      var.org,
      var.environment,
      type,
      var.instance,
      module.azure_location.short_name
    ]
  }
}
