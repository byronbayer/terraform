output "prefix_resource_group_name" {
  description = "Name of the resource group using the prefix naming convention"
  value       = azurerm_resource_group.prefix.name
}

output "postfix_resource_group_name" {
  description = "Name of the resource group using the postfix naming convention"
  value       = azurerm_resource_group.postfix.name
}

output "networking_resource_group_name" {
  description = "Name of the networking resource group"
  value       = azurerm_resource_group.networking.name
}

output "dns_resource_group_name" {
  description = "Name of the DNS resource group"
  value       = azurerm_resource_group.dns.name
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.example.name
}

output "private_endpoint_subnet_id" {
  description = "ID of the private endpoints subnet"
  value       = azurerm_subnet.private_endpoints.id
}

output "prefix_storage_account_name" {
  description = "Name of the storage account in the prefix resource group"
  value       = module.storage_account_prefix.storage_account_name
}

output "postfix_storage_account_name" {
  description = "Name of the storage account in the postfix resource group"
  value       = module.storage_account_postfix.storage_account_name
}

output "prefix_key_vault_uri" {
  description = "URI of the Key Vault in the prefix resource group"
  value       = module.keyvault_prefix.key_vault_uri
}

output "postfix_key_vault_uri" {
  description = "URI of the Key Vault in the postfix resource group"
  value       = module.keyvault_postfix.key_vault_uri
}
