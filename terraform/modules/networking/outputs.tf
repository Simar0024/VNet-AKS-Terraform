# Networking Module - Outputs

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = azurerm_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = azurerm_subnet.private.id
}

output "public_nsg_id" {
  description = "ID of the public subnet NSG"
  value       = azurerm_network_security_group.public.id
}

output "private_nsg_id" {
  description = "ID of the private subnet NSG"
  value       = azurerm_network_security_group.private.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = var.enable_nat_gateway ? azurerm_nat_gateway.main[0].id : null
}

output "nat_gateway_public_ip" {
  description = "Public IP address of NAT Gateway"
  value       = azurerm_public_ip.nat.ip_address
}

output "nat_gateway_public_ip_id" {
  description = "Public IP ID of NAT Gateway"
  value       = azurerm_public_ip.nat.id
}

output "route_table_id" {
  description = "ID of the route table for private subnet"
  value       = azurerm_route_table.private.id
}

output "bastion_subnet_id" {
  description = "The ID of the AzureBastionSubnet"
  value       = azurerm_subnet.bastion_service.id
}

output "management_subnet_id" {
  description = "The ID of the subnet for the Private VM"
  value       = azurerm_subnet.management.id
}

output "database_subnet_id" {
  description = "The ID of the delegated Database subnet"
  value       = azurerm_subnet.database.id
}

output "aks_subnet_id" {
  description = "The ID of the AKS subnet"
  value       = azurerm_subnet.aks.id
}