output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "private_endpoint_ids" {
  description = "Map of private endpoint IDs by type (blob, file, table, queue, dfs)"
  value       = { for k, v in module.private_endpoint : k => v.id }
}
