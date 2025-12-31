# Storage Account Module

This module creates an Azure Storage Account with configurable private endpoints using the Azure naming convention.

## Features

- Azure Storage Account with security best practices
- Configurable private endpoints for blob, file, table, queue, and dfs services
- Consistent naming using Azure/naming/azurerm module
- TLS 1.2 enforcement
- Public access disabled

## Usage

```hcl
module "storage_account" {
  source = "./modules/storage-account"

  naming_prefix            = ["myorg", "dev", "prefix", "01", "uks"]
  purpose                  = "gen"
  location                 = "UK South"
  resource_group_name      = azurerm_resource_group.example.name
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
  environment = "dev"
  tags        = {}
}
```

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.5.0  |
| azurerm   | >= 4.49   |

## Inputs

| Name                       | Description                                              | Type           | Default     | Required |
|----------------------------|----------------------------------------------------------|----------------|-------------|----------|
| `naming_prefix`            | Prefix to use for naming resources                       | `list(string)` | `null`      | no*      |
| `naming_suffix`            | Suffix to use for naming resources                       | `list(string)` | `null`      | no*      |
| `purpose`                  | Purpose identifier (e.g., logs, data, cache)             | `string`       | `"gen"`     | no       |
| `location`                 | Azure region for the storage account                     | `string`       | -           | yes      |
| `resource_group_name`      | Name of the resource group                               | `string`       | -           | yes      |
| `account_tier`             | Storage account tier (Standard or Premium)               | `string`       | `"Standard"`| no       |
| `account_replication_type` | Replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)    | `string`       | `"LRS"`     | no       |
| `subnet_id`                | ID of the subnet for private endpoints                   | `string`       | -           | yes      |
| `private_endpoints`        | List of private endpoint types to create                 | `list(string)` | `[]`        | no       |
| `private_dns_zone_ids`     | Map of private DNS zone IDs for each endpoint type       | `map(string)`  | `{}`        | no       |
| `environment`              | Environment name for tagging                             | `string`       | -           | yes      |
| `tags`                     | Tags to apply to resources                               | `map(string)`  | `{}`        | no       |

*Either `naming_prefix` or `naming_suffix` must be provided.

## Private Endpoint Types

The following private endpoint types are supported:

| Type    | Description                          | DNS Zone                              |
|---------|--------------------------------------|---------------------------------------|
| `blob`  | Blob storage service                 | privatelink.blob.core.windows.net     |
| `file`  | File storage service                 | privatelink.file.core.windows.net     |
| `table` | Table storage service                | privatelink.table.core.windows.net    |
| `queue` | Queue storage service                | privatelink.queue.core.windows.net    |
| `dfs`   | Data Lake Storage Gen2 (HNS enabled) | privatelink.dfs.core.windows.net      |

## Outputs

| Name                                 | Description                                    |
|--------------------------------------|------------------------------------------------|
| `storage_account_id`                 | ID of the storage account                      |
| `storage_account_name`               | Name of the storage account                    |
| `storage_account_primary_blob_endpoint` | Primary blob endpoint of the storage account |
| `private_endpoint_ids`               | Map of private endpoint IDs by type            |

## Security Features

- **TLS 1.2 Minimum**: Enforces TLS 1.2 for all connections
- **Public Access Disabled**: Both network and nested items public access disabled
- **Network ACLs**: Default deny policy with Azure Services bypass
- **Private Endpoints**: Access only via private endpoints
