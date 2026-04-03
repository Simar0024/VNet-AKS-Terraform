# Redis Module - Main Configuration

# ============================================================================
# AZURE CACHE FOR REDIS
# ============================================================================

resource "azurerm_redis_cache" "main" {
  name                          = "redis-${var.project_name}-${var.environment}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  capacity                      = var.redis_capacity
  family                        = var.redis_family
  sku_name                      = var.redis_sku_name
  non_ssl_port_enabled          = false
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  redis_configuration {
    maxmemory_policy       = "allkeys-lru"
    notify_keyspace_events = "Ex"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# ============================================================================
# PRIVATE ENDPOINT FOR REDIS
# ============================================================================

resource "azurerm_private_endpoint" "redis" {
  name                = "pe-redis"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_subnet_id

  private_service_connection {
    name                           = "psc-redis"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_redis_cache.main.id
    subresource_names              = ["redisCache"]
  }

  tags = var.tags
}

# ============================================================================
# PRIVATE DNS ZONE FOR REDIS
# ============================================================================

resource "azurerm_private_dns_zone" "redis" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# ============================================================================
# PRIVATE DNS ZONE VIRTUAL NETWORK LINK
# ============================================================================

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  name                  = "pdnsvnetlink-redis"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.redis.name
  virtual_network_id    = var.virtual_network_id

  depends_on = [
    azurerm_private_dns_zone.redis
  ]
}

# ============================================================================
# PRIVATE DNS A RECORD FOR REDIS
# ============================================================================

resource "azurerm_private_dns_a_record" "redis" {
  name                = azurerm_redis_cache.main.name
  zone_name           = azurerm_private_dns_zone.redis.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.redis.private_service_connection[0].private_ip_address]

  depends_on = [
    azurerm_private_endpoint.redis
  ]
}

# ============================================================================
# REDIS FIREWALL RULE - DENY ALL
# ============================================================================

resource "azurerm_redis_firewall_rule" "main" {
  name                = "DenyAll"
  redis_cache_name    = azurerm_redis_cache.main.name
  resource_group_name = var.resource_group_name
  start_ip            = "0.0.0.0"
  end_ip              = "0.0.0.0"
}

# ============================================================================
# DIAGNOSTIC SETTINGS FOR REDIS
# ============================================================================

resource "azurerm_monitor_diagnostic_setting" "redis" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-redis-${var.environment}"
  target_resource_id         = azurerm_redis_cache.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
