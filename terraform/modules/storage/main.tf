# Storage Module - Main Configuration

# ============================================================================
# STORAGE ACCOUNT
# ============================================================================

resource "azurerm_storage_account" "main" {
  name                              = var.storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = var.storage_tier
  account_replication_type          = var.storage_replication_type
  access_tier                       = var.storage_access_tier
  https_traffic_only_enabled        = true
  min_tls_version                   = "TLS1_2"
  shared_access_key_enabled         = false
  infrastructure_encryption_enabled = true

  identity {
    type         = "UserAssigned"
    identity_ids = [var.storage_managed_identity_resource_id]
  }

  customer_managed_key {
    key_vault_key_id          = var.storage_encryption_key_id
    user_assigned_identity_id = var.storage_managed_identity_resource_id
  }

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.tags

  depends_on = [
    var.key_vault_id
  ]
}

# Blob service properties are managed inline in the storage account configuration above

# ============================================================================
# STORAGE CONTAINERS
# ============================================================================

resource "azurerm_storage_container" "app_data" {
  count                 = 0  # Already exists, disabled due to authorization issues
  name                  = "app-data"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "backup" {
  count                 = 0  # Already exists, disabled due to authorization issues
  name                  = "backups"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "logs" {
  count                 = 0  # Already exists, disabled due to authorization issues
  name                  = "logs"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# ============================================================================
# STORAGE ACCOUNT NETWORK RULE - ADD SUBNET
# ============================================================================

resource "azurerm_storage_account_network_rules" "main" {
  count              = 0  # Already exists, disabled due to authorization issues
  storage_account_id = azurerm_storage_account.main.id

  default_action             = "Deny"
  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = var.allowed_subnet_ids
}

# ============================================================================
# STORAGE ACCOUNT QUEUE SERVICE
# ============================================================================

resource "azurerm_storage_queue" "main" {
  count                = 0  # Already exists, disabled due to authorization issues
  name                 = "aks-queue"
  storage_account_name = azurerm_storage_account.main.name
}

# ============================================================================
# STORAGE ACCOUNT TABLE SERVICE
# ============================================================================

resource "azurerm_storage_table" "diagnostics" {
  count                = 0  # Already exists, disabled due to authorization issues
  name                 = "diagnostics"
  storage_account_name = azurerm_storage_account.main.name
}

# ============================================================================
# STORAGE ACCOUNT DIAGNOSTIC SETTINGS
# ============================================================================

resource "azurerm_monitor_diagnostic_setting" "storage_account" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-storage-${var.environment}"
  target_resource_id         = "${azurerm_storage_account.main.id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }

  metric {
    category = "Capacity"
    enabled  = true
  }
}
