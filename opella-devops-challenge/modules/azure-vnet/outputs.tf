output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.this.name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.this.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes"
  value       = { for k, v in azurerm_subnet.this : k => v.address_prefixes }
}

output "network_security_group_ids" {
  description = "Map of network security group names to their IDs"
  value       = { for k, v in azurerm_network_security_group.this : k => v.id }
}

output "network_security_group_names" {
  description = "Map of subnet names to their associated NSG names"
  value       = { for k, v in azurerm_network_security_group.this : k => v.name }
}

output "resource_group_name" {
  description = "Name of the resource group containing the VNET"
  value       = var.resource_group_name
}

output "location" {
  description = "Azure region of the VNET"
  value       = var.location
}