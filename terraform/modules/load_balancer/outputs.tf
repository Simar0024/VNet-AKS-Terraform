# Load Balancer Module - Outputs

output "load_balancer_id" {
  description = "ID of the load balancer"
  value       = azurerm_lb.main.id
}

output "load_balancer_name" {
  description = "Name of the load balancer"
  value       = azurerm_lb.main.name
}

output "load_balancer_private_ip" {
  description = "Private IP address of the load balancer"
  value       = azurerm_lb.main.frontend_ip_configuration[0].private_ip_address
}

output "backend_address_pool_id" {
  description = "ID of the backend address pool"
  value       = azurerm_lb_backend_address_pool.main.id
}

output "backend_address_pool_name" {
  description = "Name of the backend address pool"
  value       = azurerm_lb_backend_address_pool.main.name
}

output "health_probe_id" {
  description = "ID of the health probe"
  value       = azurerm_lb_probe.main.id
}

output "http_rule_id" {
  description = "ID of the HTTP load balancing rule"
  value       = azurerm_lb_rule.http.id
}

output "https_rule_id" {
  description = "ID of the HTTPS load balancing rule"
  value       = azurerm_lb_rule.https.id
}
