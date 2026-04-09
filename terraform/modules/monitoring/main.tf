# Monitoring Module - Main Configuration

# ============================================================================
# LOG ANALYTICS WORKSPACE
# ============================================================================

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days

  tags = var.tags
}

# ============================================================================
# LOG ANALYTICS WORKSPACE SOLUTION (CONTAINER INSIGHTS)
# ============================================================================

resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# ============================================================================
# LOG ANALYTICS WORKSPACE SOLUTION (KEY VAULT ANALYTICS)
# ============================================================================

resource "azurerm_log_analytics_solution" "key_vault_analytics" {
  solution_name         = "KeyVaultAnalytics"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/KeyVaultAnalytics"
  }
}

# ============================================================================
# APPLICATION INSIGHTS
# ============================================================================

resource "azurerm_application_insights" "main" {
  name                = "appi-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.main.id

  tags = var.tags
}

# ============================================================================
# ACTION GROUP FOR ALERTS
# ============================================================================

resource "azurerm_monitor_action_group" "main" {
  name                = "ag-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = substr(var.project_name, 0, 12)

  email_receiver {
    name                    = "Email-AlertingNotifications"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }

  tags = var.tags
}

# ============================================================================
# ACTION GROUP - EMAIL NOTIFICATIONS
# ============================================================================
# Email receivers are now configured directly in the action group above


# 1. High CPU Alert (Platform Metric: Percentage CPU)
resource "azurerm_monitor_metric_alert" "high_cpu" {
  count               = var.enable_metric_alerts && length(var.alert_scopes) > 0 ? 1 : 0
  name                = "alert-high-cpu-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = var.alert_scopes
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }
}

# 2. Disk Health Alert (Platform Metric: Disk Read/Write Operations)
# Note: "Free Disk Space %" is NOT a platform metric. 
# We use 'Disk Read Operations/Sec' to monitor activity as a proxy.
resource "azurerm_monitor_metric_alert" "disk_activity" {
  count               = var.enable_metric_alerts && length(var.alert_scopes) > 0 ? 1 : 0
  name                = "alert-disk-activity-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = var.alert_scopes
  severity            = 3

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Disk Read Operations/Sec" 
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 1000
  }
}

# 3. Network In/Out Alert (Platform Metric: Network In Total)
resource "azurerm_monitor_metric_alert" "network_spike" {
  count               = var.enable_metric_alerts && length(var.alert_scopes) > 0 ? 1 : 0
  name                = "alert-network-in-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = var.alert_scopes
  severity            = 3

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network In Total"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 100000000 # 100MB
  }
}

# ============================================================================
# DIAGNOSTIC SETTINGS - ACTIVITY LOG
# ============================================================================

resource "azurerm_monitor_diagnostic_setting" "activity_log" {
  name                       = "diag-activity-log-${var.environment}"
  target_resource_id         = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Security"
  }

  enabled_log {
    category = "ServiceHealth"
  }

  enabled_log {
    category = "Alert"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

# ============================================================================
# DATA SOURCES
# ============================================================================

data "azurerm_client_config" "current" {}
