locals {
  # convention: {org}-{env}-postfix-{location}-{resource-type}
  naming_convention = [var.org, var.environment, "postfix", module.azure_location.short_name]

  # Base prefix for DNS zone virtual network link names
  dns_link_name_prefix = join("-", [var.org, var.environment, module.azure_location.short_name])
}
