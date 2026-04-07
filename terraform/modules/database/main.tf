# Database Module - Main Configuration

# ============================================================================
# POSTGRESQL FLEXIBLE SERVER
# ============================================================================

resource "azurerm_postgresql_flexible_server" "main" {
  name                         = var.database_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  administrator_login          = var.database_admin_user
  administrator_password       = var.database_admin_password
  storage_mb                   = var.database_storage_mb
  sku_name                     = var.database_sku_name
  version                      = var.database_version
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.enable_geo_redundant_backup
  zone                          = "1"
  delegated_subnet_id           = var.private_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.db.id
  public_network_access_enabled = false

  maintenance_window {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }

  tags = var.tags

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.db
  ]
}

# ============================================================================
# POSTGRESQL DATABASE
# ============================================================================

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# ============================================================================
# POSTGRESQL SERVER CONFIGURATION - REQUIRE SSL
# ============================================================================

resource "azurerm_postgresql_flexible_server_configuration" "require_secure_transport" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "on"
}

# ============================================================================
# POSTGRESQL SERVER CONFIGURATION - LOG CONNECTIONS
# ============================================================================

resource "azurerm_postgresql_flexible_server_configuration" "log_connections" {
  name      = "log_connections"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "on"
}

# ============================================================================
# POSTGRESQL SERVER CONFIGURATION - LOG DISCONNECTIONS
# ============================================================================

resource "azurerm_postgresql_flexible_server_configuration" "log_disconnections" {
  name      = "log_disconnections"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "on"
}

# ============================================================================
# POSTGRESQL SERVER CONFIGURATION - LOG STATEMENT
# ============================================================================

resource "azurerm_postgresql_flexible_server_configuration" "log_statement" {
  name      = "log_statement"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "mod"
}

# ============================================================================
# PRIVATE DNS ZONE FOR DATABASE
# ============================================================================

resource "azurerm_private_dns_zone" "db" {
  name                = "app-dev.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

# ============================================================================
# PRIVATE DNS ZONE VIRTUAL NETWORK LINK
# ============================================================================

resource "azurerm_private_dns_zone_virtual_network_link" "db" {
  name                  = "pdnsvnetlink-db"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  virtual_network_id    = var.virtual_network_id
}

# ============================================================================
# POSTGRESQL FIREWALL RULE - ALLOW AZURE SERVICES
# ============================================================================

resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}


# ============================================================================
# DIAGNOSTIC SETTINGS FOR DATABASE
# ============================================================================

resource "azurerm_monitor_diagnostic_setting" "database" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-db-${var.environment}"
  target_resource_id         = azurerm_postgresql_flexible_server.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "PostgreSQLLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
