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

# ============================================================================
# METRIC ALERT - HIGH CPU USAGE
# ============================================================================

resource "azurerm_monitor_metric_alert" "high_cpu" {
  for_each = var.enable_metric_alerts ? { "high_cpu" = true } : {}

  name                = "alert-high-cpu-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = var.alert_scopes

  description = "Alert when average CPU usage is high"
  severity    = 2
  enabled     = true

  criteria {
    metric_name      = "Percentage CPU"
    metric_namespace = "Microsoft.Compute/virtualMachines"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  frequency   = "PT1M"
  window_size = "PT5M"

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# ============================================================================
# METRIC ALERT - LOW DISK SPACE
# ============================================================================

resource "azurerm_monitor_metric_alert" "low_disk" {
  for_each = var.enable_metric_alerts ? { "low_disk" = true } : {}

  name                = "alert-low-disk-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = var.alert_scopes

  description = "Alert when free disk space is low"
  severity    = 2
  enabled     = true

  criteria {
    metric_name      = "Free Disk Space %"
    metric_namespace = "Microsoft.Compute/virtualMachines"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 20
  }

  frequency   = "PT5M"
  window_size = "PT5M"

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# ============================================================================
# METRIC ALERT - MEMORY PRESSURE
# ============================================================================

resource "azurerm_monitor_metric_alert" "memory_pressure" {
  for_each = var.enable_metric_alerts ? { "memory_pressure" = true } : {}

  name                = "alert-memory-pressure-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = var.alert_scopes

  description = "Alert when memory usage is high"
  severity    = 2
  enabled     = true

  criteria {
    metric_name      = "Available Memory Bytes"
    metric_namespace = "Microsoft.Compute/virtualMachines"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 536870912 # 512 MB
  }

  frequency   = "PT1M"
  window_size = "PT5M"

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
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
