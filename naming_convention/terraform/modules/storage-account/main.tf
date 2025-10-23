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
  prefix  = var.naming_prefix != null ? var.naming_prefix : []
  suffix  = var.naming_suffix != null ? var.naming_suffix : []
}

# Naming module for storage account-related resources, using the storage account name as prefix
module "naming_st" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.2"
  prefix  = var.naming_prefix != null ? [azurerm_storage_account.this.name] : []
  suffix  = var.naming_suffix != null ? [azurerm_storage_account.this.name] : []
}

resource "azurerm_storage_account" "this" {
  name                          = module.naming.storage_account.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = var.account_tier
  account_replication_type      = var.account_replication_type
  public_network_access_enabled = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = var.tags
}

# Private Endpoint for Blob
module "private_endpoint_blob" {
  count = contains(var.private_endpoints, "blob") ? 1 : 0

  source = "../private-endpoint"

  naming_prefix                  = var.naming_prefix != null ? [module.naming_st.storage_blob.name] : []
  naming_suffix                  = var.naming_suffix != null ? [module.naming_st.storage_blob.name] : []
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.subnet_id
  private_connection_resource_id = azurerm_storage_account.this.id
  subresource_names              = ["blob"]
  dns_zone_group_name            = "storage-blob-dns-zone-group"
  dns_zone_ids                   = [var.private_dns_zone_ids["blob"]]

  tags = merge(var.tags, {
    environment = var.environment
  })
}

# Private Endpoint for File
module "private_endpoint_file" {
  count = contains(var.private_endpoints, "file") ? 1 : 0

  source = "../private-endpoint"

  naming_prefix                  = var.naming_prefix != null ? [module.naming_st.storage_share.name] : []
  naming_suffix                  = var.naming_suffix != null ? [module.naming_st.storage_share.name] : []
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.subnet_id
  private_connection_resource_id = azurerm_storage_account.this.id
  subresource_names              = ["file"]
  dns_zone_group_name            = "storage-file-dns-zone-group"
  dns_zone_ids                   = [var.private_dns_zone_ids["file"]]

  tags = merge(var.tags, {
    environment = var.environment
  })
}

# Private Endpoint for Table
module "private_endpoint_table" {
  count = contains(var.private_endpoints, "table") ? 1 : 0

  source = "../private-endpoint"

  naming_prefix                  = var.naming_prefix != null ? [module.naming_st.storage_table.name] : []
  naming_suffix                  = var.naming_suffix != null ? [module.naming_st.storage_table.name] : []
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.subnet_id
  private_connection_resource_id = azurerm_storage_account.this.id
  subresource_names              = ["table"]
  dns_zone_group_name            = "storage-table-dns-zone-group"
  dns_zone_ids                   = [var.private_dns_zone_ids["table"]]

  tags = merge(var.tags, {
    environment = var.environment
  })
}

# Private Endpoint for Queue
module "private_endpoint_queue" {
  count = contains(var.private_endpoints, "queue") ? 1 : 0

  source = "../private-endpoint"

  naming_prefix                  = var.naming_prefix != null ? [module.naming_st.storage_queue.name] : []
  naming_suffix                  = var.naming_suffix != null ? [module.naming_st.storage_queue.name] : []
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.subnet_id
  private_connection_resource_id = azurerm_storage_account.this.id
  subresource_names              = ["queue"]
  dns_zone_group_name            = "storage-queue-dns-zone-group"
  dns_zone_ids                   = [var.private_dns_zone_ids["queue"]]

  tags = merge(var.tags, {
    environment = var.environment
  })
}

# Private Endpoint for DFS (Data Lake Gen2)
module "private_endpoint_dfs" {
  count = contains(var.private_endpoints, "dfs") ? 1 : 0

  source = "../private-endpoint"

  naming_prefix                  = var.naming_prefix != null ? [module.naming_st.storage_data_lake_gen2_filesystem.name] : []
  naming_suffix                  = var.naming_suffix != null ? [module.naming_st.storage_data_lake_gen2_filesystem.name] : []
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.subnet_id
  private_connection_resource_id = azurerm_storage_account.this.id
  subresource_names              = ["dfs"]
  dns_zone_group_name            = "storage-dfs-dns-zone-group"
  dns_zone_ids                   = [var.private_dns_zone_ids["dfs"]]

  tags = merge(var.tags, {
    environment = var.environment
  })
}
