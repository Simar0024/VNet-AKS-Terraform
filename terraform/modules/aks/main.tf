# AKS Module - Main Configuration

# ============================================================================
# AZURE KUBERNETES SERVICE (AKS) CLUSTER
# ============================================================================

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    node_count          = var.node_pool_default_count
    vm_size             = var.node_pool_default_vm_size
    vnet_subnet_id      = var.private_subnet_id
    os_disk_size_gb     = var.node_os_disk_size
    max_pods            = 110
    zones               = var.availability_zones
    enable_auto_scaling = true
    min_count           = var.node_pool_min_count
    max_count           = var.node_pool_max_count
    kubelet_disk_type   = "OS"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.aks_managed_identity_resource_id]
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
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
    azure_rbac_enabled     = true
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

resource "azurerm_kubernetes_cluster_node_pool" "system" {
  count = var.create_system_nodepool ? 1 : 0

  name                  = "system"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  node_count            = var.system_node_pool_count
  vm_size               = var.system_node_pool_vm_size
  vnet_subnet_id        = var.private_subnet_id
  os_disk_size_gb       = var.node_os_disk_size
  zones                 = var.availability_zones
  enable_auto_scaling   = true
  min_count             = var.system_node_pool_min_count
  max_count             = var.system_node_pool_max_count
  node_taints           = ["CriticalAddonsOnly=true:NoSchedule"]

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "compute" {
  count = var.create_compute_nodepool ? 1 : 0

  name                  = "compute"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  node_count            = var.compute_node_pool_count
  vm_size               = var.compute_node_pool_vm_size
  vnet_subnet_id        = var.private_subnet_id
  os_disk_size_gb       = var.node_os_disk_size
  zones                 = var.availability_zones
  enable_auto_scaling   = true
  min_count             = var.compute_node_pool_min_count
  max_count             = var.compute_node_pool_max_count

  tags = var.tags
}

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
