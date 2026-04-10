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
  value       = try(azurerm_storage_container.app_data[0].id, null)
}

output "storage_container_backup_id" {
  description = "ID of the backups container"
  value       = try(azurerm_storage_container.backup[0].id, null)
}

output "storage_container_logs_id" {
  description = "ID of the logs container"
  value       = try(azurerm_storage_container.logs[0].id, null)
}

output "storage_queue_id" {
  description = "ID of the storage queue"
  value       = try(azurerm_storage_queue.main[0].id, null)
}

output "storage_table_diagnostics_id" {
  description = "ID of the diagnostics table"
  value       = try(azurerm_storage_table.diagnostics[0].id, null)
}
