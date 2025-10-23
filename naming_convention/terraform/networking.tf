module "naming_networking" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.2"
  prefix  = [var.org, var.environment, "networking", module.azure_location.short_name]
}
# Resource Group for Networking
resource "azurerm_resource_group" "networking" {
  name     = module.naming_networking.resource_group.name
  location = module.azure_location.name
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = module.naming_networking.virtual_network.name
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet for private endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}
