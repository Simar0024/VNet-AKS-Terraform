# Root Outputs - Consolidated Module Outputs

# ============================================================================
# RESOURCE GROUP OUTPUTS
# ============================================================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.main.location
}

# ============================================================================
# NETWORKING OUTPUTS
# ============================================================================

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = module.networking.vnet_name
}

output "public_subnet_id" {
  description = "ID of public subnet"
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of private subnet"
  value       = module.networking.private_subnet_id
}

# ============================================================================
# SECURITY OUTPUTS
# ============================================================================

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.security.key_vault_id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.security.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.security.key_vault_uri
}

# ============================================================================
# MONITORING OUTPUTS
# ============================================================================

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_workspace_name
}

output "application_insights_id" {
  description = "ID of Application Insights"
  value       = module.monitoring.application_insights_id
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key of Application Insights"
  value       = module.monitoring.application_insights_instrumentation_key
  sensitive   = true
}

output "action_group_id" {
  description = "ID of the Monitor Action Group for alerts"
  value       = module.monitoring.action_group_id
}

# ============================================================================
# STORAGE OUTPUTS
# ============================================================================

output "storage_account_id" {
  description = "ID of the storage account"
  value       = module.storage.storage_account_id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage.storage_account_name
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = module.storage.storage_account_primary_blob_endpoint
}

output "storage_containers" {
  description = "IDs of storage containers"
  value = {
    app_data = module.storage.storage_container_app_data_id
    backup   = module.storage.storage_container_backup_id
    logs     = module.storage.storage_container_logs_id
  }
}

# ============================================================================
# DATABASE OUTPUTS
# ============================================================================

output "database_server_id" {
  description = "ID of the PostgreSQL server"
  value       = module.database.database_server_id
}

output "database_server_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = module.database.database_server_fqdn
}

output "database_name" {
  description = "Name of the created database"
  value       = module.database.database_name
}

output "database_connection_string" {
  description = "Connection string for the database"
  value       = module.database.database_connection_string
}

output "database_port" {
  description = "Database port"
  value       = module.database.database_port
}

# ============================================================================
# REDIS OUTPUTS
# ============================================================================

output "redis_id" {
  description = "ID of the Redis Cache"
  value       = module.redis.redis_id
}

output "redis_hostname" {
  description = "Hostname of the Redis cache"
  value       = module.redis.redis_hostname
}

output "redis_port" {
  description = "Port of the Redis cache"
  value       = module.redis.redis_port
}

output "redis_connection_string" {
  description = "Connection string for Redis cache"
  value       = module.redis.redis_connection_string
  sensitive   = true
}

output "redis_fqdn" {
  description = "FQDN of the Redis cache via private endpoint"
  value       = module.redis.redis_fqdn
}

# ============================================================================
# AKS OUTPUTS
# ============================================================================

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = module.aks.aks_cluster_id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.aks_cluster_name
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.aks.aks_cluster_fqdn
}

output "aks_kube_config" {
  description = "Kubernetes config for cluster access"
  value       = module.aks.aks_kube_config
  sensitive   = true
}

output "aks_node_resource_group" {
  description = "Resource group created for AKS nodes"
  value       = module.aks.aks_node_resource_group
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity"
  value       = module.aks.aks_oidc_issuer_url
}

output "aks_kubernetes_version" {
  description = "Kubernetes version deployed"
  value       = module.aks.aks_kubernetes_version
}

# ============================================================================
# APPLICATION GATEWAY OUTPUTS
# ============================================================================

output "app_gateway_id" {
  description = "ID of the Application Gateway"
  value       = module.app_gateway.app_gateway_id
}

output "app_gateway_name" {
  description = "Name of the Application Gateway"
  value       = module.app_gateway.app_gateway_name
}

output "app_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = module.app_gateway.app_gateway_public_ip
}

output "app_gateway_private_ip" {
  description = "Private IP address of the Application Gateway"
  value       = module.app_gateway.app_gateway_private_ip
}

output "app_gateway_fqdn" {
  description = "FQDN of the Application Gateway"
  value       = module.app_gateway.app_gateway_fqdn
}

output "app_gateway_backend_pool_id" {
  description = "ID of the Application Gateway backend pool"
  value       = module.app_gateway.app_gateway_backend_address_pool_id
}

# ============================================================================
# BASTION OUTPUTS
# ============================================================================

output "bastion_host_id" {
  description = "ID of the Bastion service"
  value       = module.bastion.bastion_host_id
}

output "bastion_host_name" {
  description = "Name of the Bastion service"
  value       = module.bastion.bastion_host_name
}

output "bastion_host_dns_name" {
  description = "DNS name of the Azure Bastion Host"
  value       = module.bastion.bastion_host_dns_name
}

output "bastion_public_ip" {
  description = "Public IP address of Bastion"
  value       = module.bastion.bastion_public_ip
}

output "bastion_vm_id" {
  description = "ID of the bastion jump VM (if created)"
  value       = module.bastion.bastion_vm_id
}

output "bastion_vm_name" {
  description = "Name of the bastion jump VM (if created)"
  value       = module.bastion.bastion_vm_name
}

output "bastion_vm_private_ip" {
  description = "Private IP of the bastion jump VM"
  value       = module.bastion.bastion_vm_private_ip
}

# ============================================================================
# DEPLOYMENT SUMMARY
# ============================================================================

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    project_name          = var.project_name
    environment           = var.environment
    location              = azurerm_resource_group.main.location
    vnet_cidr             = var.vnet_cidr
    aks_cluster_name      = module.aks.aks_cluster_name
    app_gateway_public_ip = module.app_gateway.app_gateway_public_ip
    bastion_public_ip     = module.bastion.bastion_public_ip
    database_server_fqdn  = module.database.database_server_fqdn
    redis_hostname        = module.redis.redis_hostname
    storage_account_name  = module.storage.storage_account_name
  }
}

