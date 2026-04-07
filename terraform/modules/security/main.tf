# Security Module - Main Configuration

# ============================================================================
# MANAGED IDENTITY FOR AKS
# ============================================================================

resource "azurerm_user_assigned_identity" "aks" {
  name                = "uami-${var.aks_cluster_name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

# ============================================================================
# MANAGED IDENTITY FOR STORAGE ENCRYPTION
# ============================================================================

resource "azurerm_user_assigned_identity" "storage" {
  name                = "uami-storage-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

# ============================================================================
# MANAGED IDENTITY FOR BASTION VM
# ============================================================================

resource "azurerm_user_assigned_identity" "bastion" {
  name                = "uami-${var.bastion_vm_name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

# ============================================================================
# AZURE KEY VAULT
# ============================================================================

resource "azurerm_key_vault" "main" {
  name                            = "kv-${var.project_name}-${var.environment}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enabled_for_deployment          = true
  enable_rbac_authorization       = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
  purge_protection_enabled        = true
  soft_delete_retention_days      = 7

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = [data.http.my_public_ip.response_body]
    virtual_network_subnet_ids = [var.private_subnet_id]
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "tf_keyvault_access" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator" # or Crypto Officer
  principal_id         = data.azurerm_client_config.current.object_id
}

# ============================================================================
# KEY VAULT KEYS
# ============================================================================

resource "azurerm_key_vault_key" "storage" {
  name         = "key-storage-encryption"
  key_vault_id = azurerm_key_vault.main.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  depends_on = [
    azurerm_key_vault.main,
    azurerm_role_assignment.tf_keyvault_access
  ]
}

resource "azurerm_key_vault_key" "disk_encryption" {
  name         = "key-disk-encryption"
  key_vault_id = azurerm_key_vault.main.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  depends_on = [
    azurerm_key_vault.main,
    azurerm_role_assignment.tf_keyvault_access
  ]
}

# ============================================================================
# DISK ENCRYPTION SET
# ============================================================================

resource "azurerm_disk_encryption_set" "main" {
  name                = "des-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  key_vault_key_id    = azurerm_key_vault_key.disk_encryption.id

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# ============================================================================
# ROLE ASSIGNMENTS FOR AKS MANAGED IDENTITY
# ============================================================================

resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = var.resource_group_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# ============================================================================
# ROLE ASSIGNMENTS FOR STORAGE ENCRYPTION
# ============================================================================

resource "azurerm_role_assignment" "storage_key_vault_access" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
}

# ============================================================================
# ROLE ASSIGNMENTS FOR DISK ENCRYPTION SET
# ============================================================================

resource "azurerm_role_assignment" "disk_encryption_key_vault" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.main.identity[0].principal_id
}


# ============================================================================
# DATA SOURCES
# ============================================================================

data "azurerm_client_config" "current" {}
data "http" "my_public_ip" {
  url = "https://ifconfig.me/ip"
}