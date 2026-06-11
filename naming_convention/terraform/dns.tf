module "naming_dns" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.2"
  prefix  = [var.org, var.environment, "dns", module.azure_location.short_name]
}
# Resource Group for DNS
resource "azurerm_resource_group" "dns" {
  name     = module.naming_dns.resource_group.name
  location = module.azure_location.name
}

# Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.dns.name
}

# Link Private DNS Zone to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "${local.dns_link_name_prefix}-kv-dns-link"
  resource_group_name   = azurerm_resource_group.dns.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false
}

# Private DNS Zone for Storage Account Blob
resource "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.dns.name
}

# Link Private DNS Zone to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  name                  = "${local.dns_link_name_prefix}-blob-dns-link"
  resource_group_name   = azurerm_resource_group.dns.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false
}

# Private DNS Zone for Storage Account File
resource "azurerm_private_dns_zone" "storage_file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.dns.name
}

# Link Private DNS Zone to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "storage_file" {
  name                  = "${local.dns_link_name_prefix}-file-dns-link"
  resource_group_name   = azurerm_resource_group.dns.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_file.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false
}

# Private DNS Zone for Storage Account Table
resource "azurerm_private_dns_zone" "storage_table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.dns.name
}

# Link Private DNS Zone to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "storage_table" {
  name                  = "${local.dns_link_name_prefix}-table-dns-link"
  resource_group_name   = azurerm_resource_group.dns.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_table.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false
}

# Private DNS Zone for Storage Account Queue
resource "azurerm_private_dns_zone" "storage_queue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.dns.name
}

# Link Private DNS Zone to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "storage_queue" {
  name                  = "${local.dns_link_name_prefix}-queue-dns-link"
  resource_group_name   = azurerm_resource_group.dns.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_queue.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false
}

# Private DNS Zone for Storage Account DFS (Data Lake Gen2)
resource "azurerm_private_dns_zone" "storage_dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.dns.name
}

# Link Private DNS Zone to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "storage_dfs" {
  name                  = "${local.dns_link_name_prefix}-dfs-dns-link"
  resource_group_name   = azurerm_resource_group.dns.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dfs.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false
}
