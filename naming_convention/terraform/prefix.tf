module "naming_prefix" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.2"
  suffix  = local.naming_convention
}

resource "azurerm_resource_group" "prefix" {
  name     = module.naming_prefix.resource_group.name
  location = module.azure_location.name
}

module "storage_account_prefix" {
  source = "git::https://github.com/byronbayer/terraform-modules.git//modules/azure/storage-account?ref=jf/initial-create"

  naming_suffix            = local.naming_convention
  location                 = azurerm_resource_group.prefix.location
  resource_group_name      = azurerm_resource_group.prefix.name
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

  tags = {}
}

module "keyvault_prefix" {
  source = "git::https://github.com/byronbayer/terraform-modules.git//modules/azure/keyvault?ref=jf/initial-create"

  naming_suffix       = local.naming_convention
  location            = azurerm_resource_group.prefix.location
  resource_group_name = azurerm_resource_group.prefix.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  subnet_id           = azurerm_subnet.private_endpoints.id
  private_dns_zone_id = azurerm_private_dns_zone.keyvault.id
  environment         = var.environment

  tags = {}
}
