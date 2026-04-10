# Bastion Module - Outputs

output "bastion_host_id" {
  description = "ID of the Azure Bastion Host"
  value       = try(azurerm_bastion_host.main[0].id, null)
}

output "bastion_host_name" {
  description = "Name of the Azure Bastion Host"
  value       = try(azurerm_bastion_host.main[0].name, null)
}

output "bastion_host_dns_name" {
  description = "DNS name of the Azure Bastion Host"
  value       = try(azurerm_bastion_host.main[0].dns_name, null)
}

output "bastion_public_ip" {
  description = "Public IP address of Bastion"
  value       = try(azurerm_public_ip.bastion[0].ip_address, null)
}

output "bastion_nsg_id" {
  description = "ID of the Bastion NSG"
  value       = azurerm_network_security_group.bastion.id
}

output "bastion_nsg_name" {
  description = "Name of the Bastion NSG"
  value       = azurerm_network_security_group.bastion.name
}

output "bastion_vm_id" {
  description = "ID of the bastion jump VM (if created)"
  value       = try(azurerm_linux_virtual_machine.bastion_vm[0].id, null)
}

output "bastion_vm_name" {
  description = "Name of the bastion jump VM (if created)"
  value       = try(azurerm_linux_virtual_machine.bastion_vm[0].name, null)
}

output "bastion_vm_private_ip" {
  description = "Private IP of the bastion jump VM"
  value       = try(azurerm_network_interface.bastion_vm[0].private_ip_address, null)
}

output "bastion_vm_nic_id" {
  description = "ID of the bastion VM network interface"
  value       = try(azurerm_network_interface.bastion_vm[0].id, null)
}
