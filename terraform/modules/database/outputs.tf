# Database Module - Outputs

output "database_server_id" {
  description = "ID of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.id
}

output "database_server_name" {
  description = "Name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.name
}

output "database_server_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "database_name" {
  description = "Name of the created database"
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "database_administrator_login" {
  description = "Administrator login for the database"
  value       = azurerm_postgresql_flexible_server.main.administrator_login
}

output "database_connection_string" {
  description = "Connection string for the database"
  value       = "postgresql://${azurerm_postgresql_flexible_server.main.administrator_login}@${azurerm_postgresql_flexible_server.main.name}:5432/${azurerm_postgresql_flexible_server_database.main.name}"
}

output "database_port" {
  description = "Database port"
  value       = 5432
}

output "database_username" {
  description = "Database username"
  value       = azurerm_postgresql_flexible_server.main.administrator_login
}
