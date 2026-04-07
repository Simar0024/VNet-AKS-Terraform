# Root Main Configuration - Module Orchestration

# ============================================================================
# NETWORKING MODULE
# ============================================================================

module "networking" {
  source = "./modules/networking"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  environment         = var.environment
  project_name        = var.project_name

  vnet_cidr                = var.vnet_cidr
  public_subnet_cidr       = var.public_subnet_cidr
  private_subnet_cidr      = var.private_subnet_cidr
  enable_nat_gateway       = var.enable_nat_gateway
  nat_gateway_idle_timeout = var.nat_gateway_idle_timeout

  tags = local.common_tags

  depends_on = [
    azurerm_resource_group.main
  ]
}

# ============================================================================
# SECURITY MODULE
# ============================================================================

module "security" {
  source = "./modules/security"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  resource_group_id   = azurerm_resource_group.main.id
  environment         = var.environment
  project_name        = var.project_name

  aks_cluster_name  = var.aks_cluster_name
  bastion_vm_name   = var.bastion_vm_name
  private_subnet_id = module.networking.private_subnet_id

  tags = local.common_tags

  depends_on = [
    module.networking
  ]
}

# ============================================================================
# MONITORING MODULE
# ============================================================================

module "monitoring" {
  source = "./modules/monitoring"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  environment         = var.environment
  project_name        = var.project_name

  log_analytics_sku    = var.log_analytics_sku
  log_retention_days   = var.log_retention_days
  alert_email          = var.alert_email
  enable_metric_alerts = var.enable_metric_alerts
  alert_scopes         = ["/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Compute/virtualMachines/vm-bastion"]

  tags = local.common_tags

  depends_on = [
    azurerm_resource_group.main
  ]
}

# ============================================================================
# STORAGE MODULE
# ============================================================================

module "storage" {
  source = "./modules/storage"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  environment         = var.environment

  storage_account_name     = var.storage_account_name
  storage_tier             = var.storage_tier
  storage_replication_type = var.storage_replication_type
  storage_access_tier      = var.storage_access_tier

  storage_encryption_key_id            = module.security.storage_encryption_key_id
  storage_managed_identity_resource_id = module.security.storage_managed_identity_resource_id
  key_vault_id                         = module.security.key_vault_id

  allowed_subnet_ids                   = [module.networking.private_subnet_id]
  blob_delete_retention_days           = var.blob_delete_retention_days
  container_soft_delete_retention_days = var.container_soft_delete_retention_days
  enable_versioning                    = var.enable_versioning

  enable_diagnostics         = var.enable_diagnostics
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  tags = local.common_tags

  depends_on = [
    module.security,
    module.monitoring,
    module.networking
  ]
}

# ============================================================================
# DATABASE MODULE
# ============================================================================

module "database" {
  source = "./modules/database"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  environment         = var.environment

  database_server_name    = var.database_server_name
  database_name           = var.database_name
  database_admin_user     = var.database_admin_user
  database_admin_password = var.database_admin_password
  database_version        = var.database_version
  database_sku_name       = var.database_sku_name
  database_storage_mb     = var.database_storage_mb

  backup_retention_days       = var.backup_retention_days
  enable_geo_redundant_backup = var.enable_geo_redundant_backup
  high_availability_mode      = var.high_availability_mode

  private_subnet_id  = module.networking.private_subnet_id
  virtual_network_id = module.networking.vnet_id

  enable_diagnostics         = var.enable_diagnostics
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  tags = local.common_tags

  depends_on = [
    module.networking,
    module.monitoring
  ]
}

# ============================================================================
# REDIS MODULE
# ============================================================================

module "redis" {
  source = "./modules/redis"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  environment         = var.environment
  project_name        = var.project_name

  redis_sku_name = var.redis_sku_name
  redis_family   = var.redis_family
  redis_capacity = var.redis_capacity

  private_subnet_id  = module.networking.private_subnet_id
  virtual_network_id = module.networking.vnet_id
  management_subnet_id = module.networking.management_subnet_id
  
  enable_diagnostics         = var.enable_diagnostics
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  tags = local.common_tags

  depends_on = [
    module.networking,
    module.monitoring
  ]
}

# ============================================================================
# AKS MODULE
# ============================================================================

module "aks" {
  source = "./modules/aks"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  environment         = var.environment

  aks_cluster_name   = var.aks_cluster_name
  dns_prefix         = var.dns_prefix
  kubernetes_version = var.kubernetes_version

  node_pool_default_count   = var.node_pool_default_count
  node_pool_default_vm_size = var.node_pool_default_vm_size
  node_pool_min_count       = var.node_pool_min_count
  node_pool_max_count       = var.node_pool_max_count
  node_os_disk_size         = var.node_os_disk_size
  availability_zones        = var.availability_zones

  private_subnet_id  = module.networking.private_subnet_id
  service_cidr       = var.service_cidr
  dns_service_ip     = var.dns_service_ip
  docker_bridge_cidr = var.docker_bridge_cidr

  aks_managed_identity_resource_id = module.security.aks_managed_identity_resource_id
  log_analytics_workspace_id       = module.monitoring.log_analytics_workspace_id
  action_group_id                  = module.monitoring.action_group_id

  aad_admin_groups     = var.aad_admin_groups
  authorized_ip_ranges = var.authorized_ip_ranges

  create_system_nodepool     = var.create_system_nodepool
  system_node_pool_count     = var.system_node_pool_count
  system_node_pool_vm_size   = var.system_node_pool_vm_size
  system_node_pool_min_count = var.system_node_pool_min_count
  system_node_pool_max_count = var.system_node_pool_max_count

  create_compute_nodepool     = var.create_compute_nodepool
  compute_node_pool_count     = var.compute_node_pool_count
  compute_node_pool_vm_size   = var.compute_node_pool_vm_size
  compute_node_pool_min_count = var.compute_node_pool_min_count
  compute_node_pool_max_count = var.compute_node_pool_max_count

  enable_diagnostics = var.enable_diagnostics

  tags = local.common_tags

  depends_on = [
    module.security,
    module.networking,
    module.monitoring
  ]
}

# ============================================================================
# APPLICATION GATEWAY MODULE
# ============================================================================

module "app_gateway" {
  source = "./modules/app_gateway"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  environment         = var.environment

  app_gateway_name     = var.app_gateway_name
  app_gateway_sku_name = var.app_gateway_sku_name
  app_gateway_sku_tier = var.app_gateway_sku_tier
  app_gateway_capacity = var.app_gateway_capacity

  app_gateway_subnet_id     = module.networking.public_subnet_id
  app_gateway_private_ip    = var.app_gateway_private_ip
  backend_pool_ip_addresses = var.backend_pool_ip_addresses

  ssl_certificate_data     = var.ssl_certificate_data
  ssl_certificate_password = var.ssl_certificate_password

  autoscale_min_capacity = var.autoscale_min_capacity
  autoscale_max_capacity = var.autoscale_max_capacity

  enable_diagnostics         = var.enable_diagnostics
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  tags = local.common_tags

  depends_on = [
    module.networking,
    module.monitoring
  ]
}

# ============================================================================
# BASTION MODULE
# ============================================================================

module "bastion" {
  source = "./modules/bastion"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  environment         = var.environment

  private_subnet_id = module.networking.private_subnet_id

  bastion_service_subnet_id = module.networking.bastion_subnet_id
  management_subnet_id      = module.networking.management_subnet_id

  bastion_vm_name       = var.bastion_vm_name
  bastion_vm_size       = var.bastion_vm_size
  bastion_admin_user    = var.bastion_admin_user
  bastion_admin_ssh_key = var.bastion_admin_ssh_key

  bastion_managed_identity_resource_id = module.security.bastion_managed_identity_resource_id
  disk_encryption_set_id               = module.security.disk_encryption_set_id
  key_vault_id                         = module.security.key_vault_id
  disk_encryption_key_id               = module.security.disk_encryption_key_id

  create_bastion_vm    = var.create_bastion_vm
  enable_vm_encryption = var.enable_vm_encryption

  enable_diagnostics         = var.enable_diagnostics
  log_analytics_workspace_id = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.OperationalInsights/workspaces/law-${var.project_name}-${var.environment}"

  tags = local.common_tags

  depends_on = [
    module.security,
    module.networking,
    module.monitoring
  ]
}

# ============================================================================
# LOAD BALANCER MODULE
# ============================================================================

module "load_balancer" {
  source = "./modules/load_balancer"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  environment         = var.environment

  load_balancer_name       = var.load_balancer_name
  private_subnet_id        = module.networking.private_subnet_id
  load_balancer_private_ip = var.load_balancer_private_ip
  lb_subnet_id             = module.networking.lb_subnet_id

  health_probe_protocol = var.health_probe_protocol
  health_probe_port     = var.health_probe_port
  health_probe_path     = var.health_probe_path

  enable_diagnostics         = var.enable_diagnostics
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  tags = local.common_tags

  depends_on = [
    module.networking,
    module.monitoring
  ]
}

# ============================================================================
# RESOURCE GROUP
# ============================================================================

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags
}

# ============================================================================
# LOCAL VALUES FOR COMMON TAGS
# ============================================================================

locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  )
}

