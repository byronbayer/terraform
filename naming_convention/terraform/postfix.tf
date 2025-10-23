


module "naming_postfix" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.2"
  prefix  = local.naming_convention_postfix
}

resource "azurerm_resource_group" "postfix" {
  name     = module.naming_postfix.resource_group.name
  location = module.azure_location.name
}

module "storage_account_postfix" {
  source = "./modules/storage-account"

  naming_prefix            = local.naming_convention_postfix
  location                 = azurerm_resource_group.postfix.location
  resource_group_name      = azurerm_resource_group.postfix.name
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

module "keyvault_postfix" {
  source = "./modules/keyvault"

  naming_prefix       = local.naming_convention_postfix
  location            = azurerm_resource_group.postfix.location
  resource_group_name = azurerm_resource_group.postfix.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  subnet_id           = azurerm_subnet.private_endpoints.id
  private_dns_zone_id = azurerm_private_dns_zone.keyvault.id
  environment         = var.environment

  tags = {}
}
