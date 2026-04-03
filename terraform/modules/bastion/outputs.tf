# Bastion Module - Outputs

output "bastion_host_id" {
  description = "ID of the Azure Bastion Host"
  value       = azurerm_bastion_host.main.id
}

output "bastion_host_name" {
  description = "Name of the Azure Bastion Host"
  value       = azurerm_bastion_host.main.name
}

output "bastion_host_dns_name" {
  description = "DNS name of the Azure Bastion Host"
  value       = azurerm_bastion_host.main.dns_name
}

output "bastion_public_ip" {
  description = "Public IP address of Bastion"
  value       = azurerm_public_ip.bastion.ip_address
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
  value       = azurerm_network_interface.bastion_vm.private_ip_address
}

output "bastion_vm_nic_id" {
  description = "ID of the bastion VM network interface"
  value       = azurerm_network_interface.bastion_vm.id
}
