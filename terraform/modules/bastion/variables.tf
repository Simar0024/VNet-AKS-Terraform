# Bastion Module - Input Variables

variable "location" {
  description = "Azure region for resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z\\s]+$", var.location))
    error_message = "Location must be a valid Azure region name."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name cannot be empty."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "bastion_service_subnet_id" {
  description = "ID of the subnet for Azure Bastion Service"
  type        = string
  default     = "AzureBastionSubnet" # This is the required name for the subnet used by Azure Bastion

  validation {
    condition     = can(regex("^/subscriptions/", var.bastion_service_subnet_id))
    error_message = "Subnet ID must be a valid Azure resource ID."
  }
}

variable "private_subnet_id" {
  description = "ID of the private subnet for bastion VM"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.private_subnet_id))
    error_message = "Subnet ID must be a valid Azure resource ID."
  }
}

variable "bastion_vm_name" {
  description = "Name of the bastion VM"
  type        = string

  validation {
    condition     = length(var.bastion_vm_name) >= 1 && length(var.bastion_vm_name) <= 64
    error_message = "Bastion VM name must be 1-64 characters."
  }
}

variable "bastion_vm_size" {
  description = "Size of the bastion VM"
  type        = string
  default     = "Standard_B2s"

  validation {
    condition     = can(regex("^Standard_", var.bastion_vm_size))
    error_message = "VM size must be a valid Azure VM SKU."
  }
}

variable "bastion_admin_user" {
  description = "Admin username for bastion VM"
  type        = string
  default     = "azureuser"

  validation {
    condition     = length(var.bastion_admin_user) >= 1 && length(var.bastion_admin_user) <= 64
    error_message = "Admin user must be 1-64 characters."
  }
}

variable "bastion_admin_ssh_key" {
  description = "SSH public key for bastion VM admin user"
  type        = string

  validation {
    condition     = can(regex("ssh-rsa|ssh-ed25519", var.bastion_admin_ssh_key))
    error_message = "Must be a valid SSH public key."
  }
}

variable "bastion_managed_identity_resource_id" {
  description = "Resource ID of the bastion managed identity"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.bastion_managed_identity_resource_id))
    error_message = "Managed identity resource ID must be a valid Azure resource ID."
  }
}

variable "disk_encryption_set_id" {
  description = "ID of the disk encryption set"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.disk_encryption_set_id))
    error_message = "Disk encryption set ID must be a valid Azure resource ID."
  }
}

variable "key_vault_id" {
  description = "ID of the Key Vault"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.key_vault_id))
    error_message = "Key Vault ID must be a valid Azure resource ID."
  }
}

variable "disk_encryption_key_id" {
  description = "ID of the disk encryption key"
  type        = string

  validation {
    condition     = can(regex("^https://", var.disk_encryption_key_id))
    error_message = "Disk encryption key ID must be a valid Key Vault key URL."
  }
}

variable "create_bastion_vm" {
  description = "Create a bastion jump box VM"
  type        = bool
  default     = true
}

variable "enable_vm_encryption" {
  description = "Enable OS disk encryption for bastion VM"
  type        = bool
  default     = true
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for Bastion"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "management_subnet_id" {
  type        = string
  description = "ID for the VM's Network Interface"
}