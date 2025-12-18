


module "naming_suffix" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.2"
  suffix  = local.naming_convention["suffix"]
}

resource "azurerm_resource_group" "suffix" {
  name     = module.naming_suffix.resource_group.name
  location = module.azure_location.name
}

module "storage_account_suffix" {
  source = "./modules/storage-account"

  naming_suffix            = local.naming_convention["suffix"]
  location                 = azurerm_resource_group.suffix.location
  resource_group_name      = azurerm_resource_group.suffix.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  subnet_id                = azurerm_subnet.private_endpoints.id
  private_endpoints        = ["blob", "file", "table", "queue", "dfs"]
  private_dns_zone_ids = {
    blob  = azurerm_private_dns_zone.storage_blob.id
    file  = azurerm_private_dns_zone.storage_file.id
    table = azurerm_private_dns_zone.storage_table.id
    queue = azurerm_private_dns_zone.storage_queue.id
    dfs   = azurerm_private_dns_zone.storage_dfs.id
  }
  environment = var.environment
  tags        = {}
}

module "keyvault_suffix" {
  source = "./modules/keyvault"

  naming_suffix       = local.naming_convention["suffix"]
  location            = azurerm_resource_group.suffix.location
  resource_group_name = azurerm_resource_group.suffix.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  subnet_id           = azurerm_subnet.private_endpoints.id
  private_dns_zone_id = azurerm_private_dns_zone.keyvault.id
  environment         = var.environment
  tags                = {}
}
