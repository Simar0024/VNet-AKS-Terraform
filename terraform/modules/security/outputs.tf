# Security Module - Outputs

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "storage_encryption_key_id" {
  description = "ID of the storage encryption key"
  value       = azurerm_key_vault_key.storage.id
}

output "disk_encryption_key_id" {
  description = "ID of the disk encryption key"
  value       = azurerm_key_vault_key.disk_encryption.id
}

output "disk_encryption_set_id" {
  description = "ID of the Disk Encryption Set"
  value       = azurerm_disk_encryption_set.main.id
}

output "aks_managed_identity_id" {
  description = "Client ID of the AKS managed identity"
  value       = azurerm_user_assigned_identity.aks.client_id
}

output "aks_managed_identity_principal_id" {
  description = "Principal ID of the AKS managed identity"
  value       = azurerm_user_assigned_identity.aks.principal_id
}

output "aks_managed_identity_resource_id" {
  description = "Resource ID of the AKS managed identity"
  value       = azurerm_user_assigned_identity.aks.id
}

output "storage_managed_identity_id" {
  description = "Client ID of the storage managed identity"
  value       = azurerm_user_assigned_identity.storage.client_id
}

output "storage_managed_identity_principal_id" {
  description = "Principal ID of the storage managed identity"
  value       = azurerm_user_assigned_identity.storage.principal_id
}

output "storage_managed_identity_resource_id" {
  description = "Resource ID of the storage managed identity"
  value       = azurerm_user_assigned_identity.storage.id
}

output "bastion_managed_identity_id" {
  description = "Client ID of the bastion managed identity"
  value       = azurerm_user_assigned_identity.bastion.client_id
}

output "bastion_managed_identity_principal_id" {
  description = "Principal ID of the bastion managed identity"
  value       = azurerm_user_assigned_identity.bastion.principal_id
}

output "bastion_managed_identity_resource_id" {
  description = "Resource ID of the bastion managed identity"
  value       = azurerm_user_assigned_identity.bastion.id
}
