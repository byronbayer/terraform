module "naming_dns" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.2"
  prefix  = [var.org, "prd", "dns", module.azure_location.short_name]
}

# Resource Group for DNS
resource "azurerm_resource_group" "dns" {
  name     = module.naming_dns.resource_group.name
  location = module.azure_location.name
}

# Map of DNS zone configurations
locals {
  dns_zones = {
    keyvault      = "privatelink.vaultcore.azure.net"
    storage_blob  = "privatelink.blob.core.windows.net"
    storage_file  = "privatelink.file.core.windows.net"
    storage_table = "privatelink.table.core.windows.net"
    storage_queue = "privatelink.queue.core.windows.net"
    storage_dfs   = "privatelink.dfs.core.windows.net"
  }
}

# Private DNS Zones
resource "azurerm_private_dns_zone" "this" {
  for_each            = local.dns_zones
  name                = each.value
  resource_group_name = azurerm_resource_group.dns.name
}

# Link Private DNS Zones to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = local.dns_zones
  name                  = "${each.key}-dns-link"
  resource_group_name   = azurerm_resource_group.dns.name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false
}
