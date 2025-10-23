terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.49"
    }
  }
}

# Naming module for the private endpoint and NIC (based on resource name prefix)
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.2"
  prefix  = var.naming_prefix != null ? var.naming_prefix : []
  suffix  = var.naming_suffix != null ? var.naming_suffix : []
}

# Naming module for private service connection (based on private endpoint name)
module "naming_pe" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.2"
  prefix  = var.naming_prefix != null ? [module.naming.private_endpoint.name] : []
  suffix  = var.naming_suffix != null ? [module.naming.private_endpoint.name] : []
}

resource "azurerm_private_endpoint" "this" {
  name                = module.naming.private_endpoint.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = module.naming_pe.private_service_connection.name
    private_connection_resource_id = var.private_connection_resource_id
    is_manual_connection           = var.is_manual_connection
    subresource_names              = var.subresource_names
  }

  private_dns_zone_group {
    name                 = var.dns_zone_group_name
    private_dns_zone_ids = var.dns_zone_ids
  }

  custom_network_interface_name = module.naming.network_interface.name

  tags = var.tags
}
