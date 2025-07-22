output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.vnet.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.vnet.subnet_ids
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.vm.ip_address
}

output "vm_ssh_connection" {
  description = "SSH connection string for the VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.vm.ip_address}"
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_primary_blob_endpoint" {
  description = "Primary blob endpoint for the storage account"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}