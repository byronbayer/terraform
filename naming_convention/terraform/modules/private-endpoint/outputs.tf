output "id" {
  description = "The ID of the Private Endpoint"
  value       = azurerm_private_endpoint.this.id
}

output "name" {
  description = "The name of the Private Endpoint"
  value       = azurerm_private_endpoint.this.name
}

output "private_ip_address" {
  description = "The private IP address associated with the private endpoint"
  value       = try(azurerm_private_endpoint.this.private_service_connection[0].private_ip_address, null)
}

output "network_interface_id" {
  description = "The ID of the network interface associated with the private endpoint"
  value       = azurerm_private_endpoint.this.network_interface[0].id
}
