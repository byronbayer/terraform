# Azure Naming Convention Terraform Project

This project demonstrates a standardized Azure naming convention implementation using Terraform and the [Azure Naming Module](https://registry.terraform.io/modules/Azure/naming/azurerm).

## Features

- **Consistent Naming Convention**: Uses a structured naming pattern across all resources
- **Reusable Modules**: Key Vault, Storage Account, and Private Endpoint modules
- **Private Networking**: All resources are deployed with private endpoints
- **Security Best Practices**: TLS 1.2 enforcement, disabled public access, purge protection options

## Naming Convention Pattern

Resources follow this naming pattern:

```
{org}-{environment}-{type}-{instance}-{location}-{purpose}
```

| Component     | Description                              | Example     |
|---------------|------------------------------------------|-------------|
| `org`         | Organization identifier                  | `myorg`     |
| `environment` | Environment name (dev, tst, uat, prd)    | `dev`       |
| `type`        | Naming type (prefix or suffix)           | `prefix`    |
| `instance`    | Instance identifier (two-digit)          | `01`        |
| `location`    | Azure region short name                  | `uks`       |
| `purpose`     | Resource purpose identifier              | `gen`, `logs` |

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- An Azure subscription with appropriate permissions

## Quick Start

1. **Login to Azure**
   ```powershell
   az login
   ```

2. **Initialize Terraform**
   ```powershell
   terraform init
   ```

3. **Review the plan**
   ```powershell
   terraform plan -var="subscription_id=<YOUR_SUBSCRIPTION_ID>"
   ```

4. **Apply the configuration**
   ```powershell
   terraform apply -var="subscription_id=<YOUR_SUBSCRIPTION_ID>"
   ```

## Using the Deployment Script

A PowerShell script is provided for streamlined deployments:

```powershell
# Deploy infrastructure
.\scripts\Invoke-TerraformDeployment.ps1 -SubscriptionId "<YOUR_SUBSCRIPTION_ID>"

# Destroy infrastructure
.\scripts\Invoke-TerraformDeployment.ps1 -SubscriptionId "<YOUR_SUBSCRIPTION_ID>" -Destroy
```

## Variables

| Name              | Description                           | Type     | Default      | Required |
|-------------------|---------------------------------------|----------|--------------|----------|
| `subscription_id` | The Azure subscription ID             | `string` | -            | yes      |
| `location`        | The Azure location to deploy resources| `string` | `UK South`   | no       |
| `org`             | The organization name                 | `string` | `myorg`      | no       |
| `environment`     | Environment name (dev/tst/uat/prd)    | `string` | `dev`        | no       |
| `instance`        | Instance identifier (01, 02, etc.)    | `string` | `01`         | no       |

## Outputs

| Name                      | Description                           |
|---------------------------|---------------------------------------|
| `resource_group_prefix`   | The prefix resource group details     |
| `resource_group_dns`      | The DNS resource group details        |
| `storage_accounts`        | Map of storage account outputs        |
| `keyvaults`               | Map of key vault outputs              |
| `private_dns_zones`       | Map of private DNS zone IDs           |
| `virtual_network`         | Virtual network details               |
| `private_endpoint_subnet` | Private endpoint subnet details       |

## Project Structure

```
terraform/
├── data.tf                 # Data sources
├── dns.tf                  # Private DNS zones and VNet links
├── locals.tf               # Local values and naming convention
├── location.tf             # Azure location module
├── networking.tf           # VNet and subnet configuration
├── outputs.tf              # Root outputs
├── prefix.tf               # Resources using prefix naming
├── provider.tf             # Provider configuration
├── suffix.tf               # Resources using suffix naming (commented)
├── variables.tf            # Input variables
└── modules/
    ├── keyvault/           # Key Vault module
    ├── private-endpoint/   # Private Endpoint module
    └── storage-account/    # Storage Account module
```

## Modules

### Key Vault Module

Creates an Azure Key Vault with private endpoint integration.

See [modules/keyvault/README.md](modules/keyvault/README.md) for details.

### Storage Account Module

Creates an Azure Storage Account with configurable private endpoints.

See [modules/storage-account/README.md](modules/storage-account/README.md) for details.

### Private Endpoint Module

Generic module for creating private endpoints with DNS integration.

See [modules/private-endpoint/README.md](modules/private-endpoint/README.md) for details.

## Security Features

- **TLS 1.2 Enforcement**: All storage accounts require TLS 1.2 minimum
- **Private Endpoints**: Resources are accessible only via private endpoints
- **Network ACLs**: Default deny with Azure Services bypass
- **Purge Protection**: Configurable Key Vault purge protection (defaults to enabled)
- **Public Access Disabled**: Both storage accounts and key vaults have public access disabled

## License

This project is provided as-is for demonstration purposes.
