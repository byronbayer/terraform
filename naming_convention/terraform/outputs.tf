output "resource_group_prefix" {
  description = "The prefix resource group"
  value = {
    id       = azurerm_resource_group.prefix.id
    name     = azurerm_resource_group.prefix.name
    location = azurerm_resource_group.prefix.location
  }
}

output "resource_group_dns" {
  description = "The DNS resource group"
  value = {
    id       = azurerm_resource_group.dns.id
    name     = azurerm_resource_group.dns.name
    location = azurerm_resource_group.dns.location
  }
}

output "storage_accounts" {
  description = "Map of storage account outputs"
  value = {
    prefix = {
      id   = module.storage_account_prefix.storage_account_id
      name = module.storage_account_prefix.storage_account_name
    }
    prefix_logs = {
      id   = module.storage_account_prefix_logs.storage_account_id
      name = module.storage_account_prefix_logs.storage_account_name
    }
  }
}

output "keyvaults" {
  description = "Map of key vault outputs"
  value = {
    prefix = {
      id   = module.keyvault_prefix.key_vault_id
      name = module.keyvault_prefix.key_vault_name
      uri  = module.keyvault_prefix.key_vault_uri
    }
    prefix_app = {
      id   = module.keyvault_prefix_app.key_vault_id
      name = module.keyvault_prefix_app.key_vault_name
      uri  = module.keyvault_prefix_app.key_vault_uri
    }
  }
}

output "private_dns_zones" {
  description = "Map of private DNS zone IDs"
  value       = { for k, v in azurerm_private_dns_zone.this : k => v.id }
}

output "virtual_network" {
  description = "Virtual network details"
  value = {
    id   = azurerm_virtual_network.example.id
    name = azurerm_virtual_network.example.name
  }
}

output "private_endpoint_subnet" {
  description = "Private endpoint subnet details"
  value = {
    id   = azurerm_subnet.private_endpoints.id
    name = azurerm_subnet.private_endpoints.name
  }
}
