# Load Balancer Module - Main Configuration

# ============================================================================
# INTERNAL LOAD BALANCER
# ============================================================================

resource "azurerm_lb" "main" {
  name                = var.load_balancer_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  sku_tier            = "Regional"

  frontend_ip_configuration {
    name                          = "ilb-frontend-ip"
    subnet_id                     = var.lb_subnet_id # Use the non-delegated ID
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# ============================================================================
# BACKEND ADDRESS POOL
# ============================================================================

resource "azurerm_lb_backend_address_pool" "main" {
  name            = "ilb-backend-pool"
  loadbalancer_id = azurerm_lb.main.id
}

# ============================================================================
# HEALTH PROBE
# ============================================================================

resource "azurerm_lb_probe" "main" {
  name                = "ilb-health-probe"
  loadbalancer_id     = azurerm_lb.main.id
  protocol            = var.health_probe_protocol
  port                = var.health_probe_port
  interval_in_seconds = 15
  number_of_probes    = 2
}

# ============================================================================
# LOAD BALANCING RULES - HTTP
# ============================================================================

resource "azurerm_lb_rule" "http" {
  name                           = "ilb-rule-http"
  loadbalancer_id                = azurerm_lb.main.id
  frontend_ip_configuration_name = "ilb-frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.main.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  idle_timeout_in_minutes        = 4
  enable_floating_ip             = false
  enable_tcp_reset               = true
  load_distribution              = "Default"
}

resource "azurerm_lb_rule" "https" {
  name                           = "ilb-rule-https"
  loadbalancer_id                = azurerm_lb.main.id
  frontend_ip_configuration_name = "ilb-frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.main.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  idle_timeout_in_minutes        = 4
  enable_floating_ip             = false
  enable_tcp_reset               = true
  load_distribution              = "Default"
}

# Outbound rules are configured at the backend pool level

# ============================================================================
# DIAGNOSTIC SETTINGS FOR LOAD BALANCER
# ============================================================================

resource "azurerm_monitor_diagnostic_setting" "load_balancer" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-ilb-${var.environment}"
  target_resource_id         = azurerm_lb.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
