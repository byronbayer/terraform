# Key Vault Module

This module creates an Azure Key Vault with private endpoint integration using the Azure naming convention.

## Features

- Azure Key Vault with configurable purge protection
- Private endpoint with DNS zone integration
- Consistent naming using Azure/naming/azurerm module
- Network ACLs with default deny policy
- Public network access disabled

## Usage

```hcl
module "keyvault" {
  source = "./modules/keyvault"

  naming_prefix       = ["myorg", "dev", "prefix", "01", "uks"]
  purpose             = "gen"
  location            = "UK South"
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  subnet_id           = azurerm_subnet.private_endpoints.id
  private_dns_zone_id = azurerm_private_dns_zone.keyvault.id
  environment         = "dev"

  # Optional - defaults to true
  purge_protection_enabled = true

  tags = {
    Environment = "dev"
  }
}
```

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.5.0  |
| azurerm   | >= 4.49   |

## Inputs

| Name                       | Description                                              | Type           | Default | Required |
|----------------------------|----------------------------------------------------------|----------------|---------|----------|
| `naming_prefix`            | Prefix components for the naming module                  | `list(string)` | `null`  | no*      |
| `naming_suffix`            | Suffix components for the naming module                  | `list(string)` | `null`  | no*      |
| `purpose`                  | Purpose identifier (e.g., secrets, certs, keys)          | `string`       | `"gen"` | no       |
| `location`                 | The Azure location for the Key Vault                     | `string`       | -       | yes      |
| `resource_group_name`      | The name of the resource group                           | `string`       | -       | yes      |
| `tenant_id`                | The Azure AD tenant ID                                   | `string`       | -       | yes      |
| `subnet_id`                | The subnet ID for the private endpoint                   | `string`       | -       | yes      |
| `private_dns_zone_id`      | The private DNS zone ID for Key Vault                    | `string`       | -       | yes      |
| `environment`              | The environment name                                     | `string`       | -       | yes      |
| `purge_protection_enabled` | Whether purge protection is enabled                      | `bool`         | `true`  | no       |
| `tags`                     | Tags to apply to resources                               | `map(string)`  | `{}`    | no       |

*Either `naming_prefix` or `naming_suffix` must be provided.

## Outputs

| Name             | Description                        |
|------------------|------------------------------------|
| `key_vault_id`   | The ID of the Key Vault            |
| `key_vault_name` | The name of the Key Vault          |
| `key_vault_uri`  | The URI of the Key Vault           |

## Security Considerations

- **Purge Protection**: Enabled by default. When enabled, the Key Vault and its objects cannot be permanently deleted during the retention period (default 90 days).
- **Soft Delete**: Automatically enabled by Azure.
- **Network ACLs**: Configured with default deny policy, allowing only Azure Services bypass.
- **Public Access**: Disabled - access only via private endpoint.
