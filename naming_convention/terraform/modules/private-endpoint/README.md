# Private Endpoint Module

A reusable Terraform module for creating Azure Private Endpoints with standardized hierarchical naming.

## Features

- **Hierarchical Naming**: Automatically creates two naming module instances:
  - `naming`: For the private endpoint and network interface (based on parent resource name)
  - `naming_pe`: For the private service connection (based on private endpoint name)
- **Consistent Structure**: Ensures all private endpoints follow the same naming pattern
- **Flexible**: Works with any Azure resource that supports private endpoints
- **DNS Integration**: Supports private DNS zone groups for automatic DNS registration

## Naming Hierarchy

The module implements the following naming hierarchy:

```
Parent Resource Name (passed as naming_prefix)
  ├─ Private Endpoint: <prefix>-pe
  ├─ Network Interface: <prefix>-nic
  └─ Private Service Connection: <prefix>-pe-psc
```

### Example Naming Output

For a Key Vault named `myorg-dev-postfix-uks-kv`:
- Private Endpoint: `myorg-dev-postfix-uks-kv-pe`
- Network Interface: `myorg-dev-postfix-uks-kv-nic`
- Private Service Connection: `myorg-dev-postfix-uks-kv-pe-psc`

For a Storage Blob named `myorgdevpostfixuksst-blob`:
- Private Endpoint: `myorgdevpostfixuksst-blob-pe`
- Network Interface: `myorgdevpostfixuksst-blob-nic`
- Private Service Connection: `myorgdevpostfixuksst-blob-pe-psc`

## Usage

### Basic Example

```hcl
module "kv_private_endpoint" {
  source = "./modules/private-endpoint"

  naming_prefix                  = ["myorg-dev-postfix-uks-kv"]
  location                       = "uksouth"
  resource_group_name            = "my-rg"
  subnet_id                      = azurerm_subnet.example.id
  private_connection_resource_id = azurerm_key_vault.example.id
  subresource_names              = ["vault"]
  dns_zone_group_name            = "keyvault-dns-zone-group"
  dns_zone_ids                   = [azurerm_private_dns_zone.kv.id]

  tags = {
    environment = "dev"
  }
}
```

### Storage Account Example

```hcl
module "storage_blob_pe" {
  source = "./modules/private-endpoint"

  naming_prefix                  = [module.naming_st.storage_blob.name]
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.subnet_id
  private_connection_resource_id = azurerm_storage_account.example.id
  subresource_names              = ["blob"]
  dns_zone_group_name            = "storage-blob-dns-zone-group"
  dns_zone_ids                   = [var.private_dns_zone_ids["blob"]]

  tags = var.tags
}
```

## Common Subresource Names

| Azure Resource        | Subresource Name(s)                                      |
|-----------------------|---------------------------------------------------------|
| Key Vault             | `vault`                                                 |
| Storage Account       | `blob`, `file`, `table`, `queue`, `dfs`, `web`         |
| SQL Database          | `sqlServer`                                             |
| Cosmos DB             | `sql`, `mongodb`, `cassandra`, `gremlin`, `table`      |
| App Service           | `sites`                                                 |
| PostgreSQL            | `postgresqlServer`                                      |
| MySQL                 | `mysqlServer`                                           |
| Container Registry    | `registry`                                              |
| Event Hub             | `namespace`                                             |
| Service Bus           | `namespace`                                             |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| naming_prefix | Prefix for naming the private endpoint (typically the parent resource name) | `list(string)` | n/a | yes |
| naming_suffix | Optional suffix for naming the private endpoint | `list(string)` | `null` | no |
| location | Azure region where the private endpoint will be created | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| subnet_id | ID of the subnet where the private endpoint will be created | `string` | n/a | yes |
| private_connection_resource_id | The ID of the resource to connect to via private endpoint | `string` | n/a | yes |
| subresource_names | List of subresource names which the Private Endpoint is able to connect to | `list(string)` | n/a | yes |
| is_manual_connection | Does the Private Endpoint require manual approval from the remote resource owner? | `bool` | `false` | no |
| dns_zone_group_name | Name of the Private DNS Zone Group | `string` | n/a | yes |
| dns_zone_ids | List of Private DNS Zone IDs to associate with the private endpoint | `list(string)` | n/a | yes |
| tags | Tags to apply to the private endpoint | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Private Endpoint |
| name | The name of the Private Endpoint |
| private_ip_address | The private IP address associated with the private endpoint |
| network_interface_id | The ID of the network interface associated with the private endpoint |

## Internal Module Structure

The module creates:
1. **Two Azure Naming Module Instances**:
   - `naming`: Generates names for PE and NIC based on the parent resource
   - `naming_pe`: Generates names for PSC based on the PE name
   
2. **One Private Endpoint Resource** with:
   - Private Service Connection
   - Private DNS Zone Group
   - Custom Network Interface Name

## Benefits

- **Reduced Code Duplication**: Eliminates ~25 lines of boilerplate per private endpoint
- **Consistent Naming**: Ensures all private endpoints follow the same hierarchical pattern
- **Maintainability**: Changes to PE structure only need to happen in one place
- **Reusability**: Can be used across different resource types (Key Vault, Storage, SQL, etc.)
- **Type Safety**: Strong typing for all variables with clear descriptions

## Version Requirements

- Terraform >= 1.0
- Azure Naming Module >= 0.4.2
- AzureRM Provider >= 4.0
