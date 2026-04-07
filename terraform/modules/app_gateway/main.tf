# Application Gateway Module - Main Configuration

# ============================================================================
# PUBLIC IP FOR APPLICATION GATEWAY
# ============================================================================

resource "azurerm_public_ip" "app_gateway" {
  name                = "pip-appgw-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"

  tags = var.tags
}

# ============================================================================
# NSG FOR APPLICATION GATEWAY SUBNET
# ============================================================================

resource "azurerm_network_security_group" "app_gateway" {
  name                = "nsg-appgw-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# ============================================================================
# APPLICATION GATEWAY
# ============================================================================

resource "azurerm_application_gateway" "main" {
  name                = var.app_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
  }
   # Autoscaling
  autoscale_configuration {
     min_capacity = 1
     max_capacity = 5
   }

  gateway_ip_configuration {
    name      = "appgw-ipconfig"
    subnet_id = var.app_gateway_subnet_id
  }

  frontend_ip_configuration {
    name                 = "appgw-feip"
    public_ip_address_id = azurerm_public_ip.app_gateway.id
  }

  frontend_ip_configuration {
    name                          = "appgw-privateip"
    subnet_id                     = var.app_gateway_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.app_gateway_private_ip
  }

  # HTTP Frontend Port
  frontend_port {
    name = "appgw-http-port"
    port = 80
  }

  # HTTPS Frontend Port
  frontend_port {
    name = "appgw-https-port"
    port = 443
  }

  # Backend Address Pools
  backend_address_pool {
    name         = "appgw-be-pool"
    ip_addresses = var.backend_pool_ip_addresses
  }

  # Backend HTTP Settings
  backend_http_settings {
    name                  = "appgw-be-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  backend_http_settings {
    name                  = "appgw-be-https-settings"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 20
  }

  # HTTP Request Routing Rule
  request_routing_rule {
    name                       = "appgw-http-rule"
    rule_type                  = "Basic"
    http_listener_name         = "appgw-http-listener"
    backend_address_pool_name  = "appgw-be-pool"
    backend_http_settings_name = "appgw-be-http-settings"
  }

  # HTTPS Request Routing Rule
  request_routing_rule {
    name                       = "appgw-https-rule"
    rule_type                  = "Basic"
    http_listener_name         = "appgw-https-listener"
    backend_address_pool_name  = "appgw-be-pool"
    backend_http_settings_name = "appgw-be-https-settings"
  }

  # HTTP Listener
  http_listener {
    name                           = "appgw-http-listener"
    frontend_ip_configuration_name = "appgw-feip"
    frontend_port_name             = "appgw-http-port"
    protocol                       = "Http"
  }

  # HTTPS Listener
  http_listener {
    name                           = "appgw-https-listener"
    frontend_ip_configuration_name = "appgw-feip"
    frontend_port_name             = "appgw-https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "appgw-ssl-cert"
  }

  # SSL Certificate
 ssl_certificate {
  name     = "appgw-ssl-cert"
  data     = filebase64("${path.module}/certificates/appgw.pfx")
  password = var.ssl_certificate_password
}

  # WAF Policy
  waf_configuration {
    enabled                  = true
    firewall_mode            = "Detection"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.2"
    request_body_check       = true
    file_upload_limit_mb     = 100
    max_request_body_size_kb = 128
  }

 

  tags = var.tags

  depends_on = [
    azurerm_public_ip.app_gateway
  ]
}

# ============================================================================
# DIAGNOSTIC SETTINGS FOR APPLICATION GATEWAY
# ============================================================================

resource "azurerm_monitor_diagnostic_setting" "app_gateway" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-appgw-${var.environment}"
  target_resource_id         = azurerm_application_gateway.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
