# AKS Module - Main Configuration

# ============================================================================
# AZURE KUBERNETES SERVICE (AKS) CLUSTER
# ============================================================================

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  private_cluster_enabled = true
  dns_prefix          = var.dns_prefix
  kubernetes_version  = "1.34.4"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name                = "default"
    node_count          = var.aks_enable_auto_scaling ? null : var.node_pool_default_count
    vm_size             = var.node_pool_default_vm_size
    vnet_subnet_id      = var.private_subnet_id
    os_disk_size_gb     = var.node_os_disk_size
    max_pods            = 110
    zones               = var.availability_zones
    enable_auto_scaling = var.aks_enable_auto_scaling
    min_count           = var.aks_enable_auto_scaling ? var.node_pool_min_count : null
    max_count           = var.aks_enable_auto_scaling ? var.node_pool_max_count : null
    kubelet_disk_type   = "OS"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.aks_managed_identity_resource_id]
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    outbound_type  = "userAssignedNATGateway"
    service_cidr      = "172.16.0.0/16"
    dns_service_ip    = "172.16.0.10"
    load_balancer_sku = "standard"
  }

  http_application_routing_enabled = false

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
    admin_group_object_ids = var.aad_admin_groups
  }

  api_server_access_profile {
    authorized_ip_ranges = var.authorized_ip_ranges
  }

  depends_on = [
    var.aks_managed_identity_resource_id
  ]

  tags = var.tags
}

# ============================================================================
# ADDITIONAL AKS NODE POOLS
# ============================================================================

# Auto-scaler configuration is set within the cluster configuration above
# DIAGNOSTIC SETTINGS FOR AKS
# ============================================================================

resource "azurerm_monitor_diagnostic_setting" "aks" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-aks-${var.environment}"
  target_resource_id         = azurerm_kubernetes_cluster.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "cluster-autoscaler"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "guard"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# ============================================================================
# AKS CLUSTER MONITORING METRIC ALERT
# ============================================================================

resource "azurerm_monitor_metric_alert" "aks_node_cpu" {
  count = var.enable_diagnostics ? 1 : 0

  name                = "alert-aks-high-node-cpu-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_kubernetes_cluster.main.id]

  description = "Alert when AKS node CPU is high"
  severity    = 2
  enabled     = true

  criteria {
    metric_name      = "node_cpu_usage_percentage"
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  frequency   = "PT5M"
  window_size = "PT5M"

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}


data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "aks_admin" {
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}