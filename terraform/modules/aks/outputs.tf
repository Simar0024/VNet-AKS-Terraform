# AKS Module - Outputs

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "aks_kube_config" {
  description = "Kubernetes config for cluster access"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "aks_client_certificate" {
  description = "Client certificate for cluster authentication"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].client_certificate
  sensitive   = true
}

output "aks_client_key" {
  description = "Client key for cluster authentication"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].client_key
  sensitive   = true
}

output "aks_cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "aks_node_resource_group" {
  description = "Resource group created for AKS nodes"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "aks_identity_principal_id" {
  description = "Principal ID of the AKS cluster identity"
  value       = azurerm_kubernetes_cluster.main.identity[0].principal_id
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity"
  value       = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "aks_kubernetes_version" {
  description = "Kubernetes version deployed"
  value       = azurerm_kubernetes_cluster.main.kubernetes_version
}

output "default_node_pool_id" {
  description = "ID of the default node pool"
  value       = azurerm_kubernetes_cluster.main.id
}

output "system_node_pool_id" {
  description = "ID of the system node pool (if created)"
  value       = try(azurerm_kubernetes_cluster_node_pool.system[0].id, null)
}

output "compute_node_pool_id" {
  description = "ID of the compute node pool (if created)"
  value       = try(azurerm_kubernetes_cluster_node_pool.compute[0].id, null)
}
