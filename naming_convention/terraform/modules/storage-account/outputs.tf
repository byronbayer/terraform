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

output "private_endpoint_blob_id" {
  description = "ID of the blob private endpoint"
  value       = try(module.private_endpoint_blob[0].id, null)
}

output "private_endpoint_file_id" {
  description = "ID of the file private endpoint"
  value       = try(module.private_endpoint_file[0].id, null)
}

output "private_endpoint_table_id" {
  description = "ID of the table private endpoint"
  value       = try(module.private_endpoint_table[0].id, null)
}

output "private_endpoint_queue_id" {
  description = "ID of the queue private endpoint"
  value       = try(module.private_endpoint_queue[0].id, null)
}

output "private_endpoint_dfs_id" {
  description = "ID of the dfs private endpoint"
  value       = try(module.private_endpoint_dfs[0].id, null)
}
