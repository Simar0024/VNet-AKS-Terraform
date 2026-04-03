# Application Gateway Module - Outputs

output "app_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

output "app_gateway_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.main.name
}

output "app_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.app_gateway.ip_address
}

output "app_gateway_private_ip" {
  description = "Private IP address of the Application Gateway"
  value       = azurerm_application_gateway.main.frontend_ip_configuration[1].private_ip_address
}

output "app_gateway_fqdn" {
  description = "FQDN of the Application Gateway"
  value       = azurerm_public_ip.app_gateway.fqdn
}

output "app_gateway_backend_address_pool_id" {
  description = "ID of the backend address pool"
  value       = azurerm_application_gateway.main.id
}

output "nsg_id" {
  description = "ID of the Application Gateway NSG"
  value       = azurerm_network_security_group.app_gateway.id
}

output "nsg_name" {
  description = "Name of the Application Gateway NSG"
  value       = azurerm_network_security_group.app_gateway.name
}
