# Storage Module - Outputs

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "storage_account_primary_queue_endpoint" {
  description = "Primary queue endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_queue_endpoint
}

output "storage_account_primary_table_endpoint" {
  description = "Primary table endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_table_endpoint
}

output "storage_container_app_data_id" {
  description = "ID of the app-data container"
  value       = azurerm_storage_container.app_data.id
}

output "storage_container_backup_id" {
  description = "ID of the backups container"
  value       = azurerm_storage_container.backup.id
}

output "storage_container_logs_id" {
  description = "ID of the logs container"
  value       = azurerm_storage_container.logs.id
}

output "storage_queue_id" {
  description = "ID of the storage queue"
  value       = azurerm_storage_queue.main.id
}

output "storage_table_diagnostics_id" {
  description = "ID of the diagnostics table"
  value       = azurerm_storage_table.diagnostics.id
}
