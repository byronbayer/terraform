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

# Naming module for storage account-related resources, using the storage account name as prefix
module "naming_st" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.2"
  prefix  = var.naming_prefix != null ? [azurerm_storage_account.this.name] : []
  suffix  = var.naming_suffix != null ? [azurerm_storage_account.this.name] : []
}

resource "azurerm_storage_account" "this" {
  name                            = module.naming.storage_account.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  public_network_access_enabled   = false
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = var.tags
}

# Local map for private endpoint configurations
locals {
  endpoint_config = {
    blob  = module.naming_st.storage_blob.name
    file  = module.naming_st.storage_share.name
    table = module.naming_st.storage_table.name
    queue = module.naming_st.storage_queue.name
    dfs   = module.naming_st.storage_data_lake_gen2_filesystem.name
  }

  # Filter to only include requested endpoints
  active_endpoints = { for k, v in local.endpoint_config : k => v if contains(var.private_endpoints, k) }
}

# Private Endpoints using for_each
module "private_endpoint" {
  for_each = local.active_endpoints

  source = "../private-endpoint"

  naming_prefix                  = var.naming_prefix != null ? [each.value] : []
  naming_suffix                  = var.naming_suffix != null ? [each.value] : []
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.subnet_id
  private_connection_resource_id = azurerm_storage_account.this.id
  subresource_names              = [each.key]
  dns_zone_group_name            = "storage-${each.key}-dns-zone-group"
  dns_zone_ids                   = [var.private_dns_zone_ids[each.key]]

  tags = merge(var.tags, {
    environment = var.environment
  })
}
