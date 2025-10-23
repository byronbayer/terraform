output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.this.id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.this.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.this.vault_uri
}

output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = module.private_endpoint.id
}

output "private_endpoint_ip" {
  description = "Private IP address of the private endpoint"
  value       = module.private_endpoint.private_ip_address
}
