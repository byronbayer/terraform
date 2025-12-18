terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.49"
    }
  }
}

# Use the Azure naming module within this module
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.2"
  prefix  = var.naming_prefix != null ? concat(var.naming_prefix, [var.purpose]) : [var.purpose]
  suffix  = var.naming_suffix != null ? concat(var.naming_suffix, [var.purpose]) : [var.purpose]
}

# Second naming module for Key Vault-related resources, using the Key Vault name as prefix
module "naming_kv" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.2"
  prefix  = var.naming_prefix != null ? [module.naming.key_vault.name] : []
  suffix  = var.naming_suffix != null ? [module.naming.key_vault.name] : []
}

resource "azurerm_key_vault" "this" {
  name                     = module.naming.key_vault.name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  tenant_id                = var.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = false

  # Enable for private endpoint
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = []
  }

  # Disable public network access when using private endpoint
  public_network_access_enabled = false

  tags = var.tags
}

# Private Endpoint for Key Vault
module "private_endpoint" {
  source = "../private-endpoint"

  naming_prefix                  = var.naming_prefix != null ? [azurerm_key_vault.this.name] : []
  naming_suffix                  = var.naming_suffix != null ? [azurerm_key_vault.this.name] : []
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.subnet_id
  private_connection_resource_id = azurerm_key_vault.this.id
  subresource_names              = ["vault"]
  dns_zone_group_name            = "keyvault-dns-zone-group"
  dns_zone_ids                   = [var.private_dns_zone_id]

  tags = merge(var.tags, {
    environment = var.environment
  })
}
