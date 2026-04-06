# Database Module - Input Variables

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

variable "database_server_name" {
  description = "Name of the PostgreSQL server (must be globally unique)"
  type        = string

  validation {
    condition     = length(var.database_server_name) >= 3 && length(var.database_server_name) <= 63 && can(regex("^[a-z0-9-]+$", var.database_server_name))
    error_message = "Server name must be 3-63 lowercase alphanumeric and hyphens, no hyphens at start or end."
  }
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z_][a-zA-Z0-9_]*$", var.database_name))
    error_message = "Database name must start with a letter or underscore, followed by alphanumeric or underscores."
  }
}

variable "database_admin_user" {
  description = "Administrator username for the database"
  type        = string

  validation {
    condition     = length(var.database_admin_user) >= 2 && length(var.database_admin_user) <= 16
    error_message = "Admin username must be 2-16 characters."
  }
}

variable "database_admin_password" {
  description = "Administrator password for the database (must be complex)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.database_admin_password) >= 14 && can(regex("[a-z]", var.database_admin_password)) && can(regex("[A-Z]", var.database_admin_password)) && can(regex("[0-9]", var.database_admin_password))
    error_message = "Password must be at least 14 characters with lowercase, uppercase, and numbers."
  }
}

variable "database_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"

  validation {
    condition     = contains(["11", "12", "13", "14", "15", "16"], var.database_version)
    error_message = "PostgreSQL version must be 11, 12, 13, 14, 15, 16."
  }
}

variable "database_sku_name" {
  description = "SKU name for the database server"
  type        = string
  default     = "B_Standard_B2s"

  validation {
    condition     = can(regex("^(B|D|E)_Standard_", var.database_sku_name))
    error_message = "SKU name must be a valid PostgreSQL Flexible Server SKU."
  }
}

variable "database_storage_mb" {
  description = "Storage size in MB"
  type        = number
  default     = 32768

  validation {
    condition     = var.database_storage_mb >= 32768 && var.database_storage_mb <= 16777216
    error_message = "Storage must be between 32GB (32768 MB) and 16TB (16777216 MB)."
  }
}

variable "backup_retention_days" {
  description = "Backup retention days"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Backup retention days must be between 7 and 35."
  }
}

variable "enable_geo_redundant_backup" {
  description = "Enable geo-redundant backup"
  type        = bool
  default     = true
}

variable "high_availability_mode" {
  description = "High availability mode (Disabled, ZoneRedundant)"
  type        = string
  default     = "ZoneRedundant"

  validation {
    condition     = contains(["Disabled", "ZoneRedundant"], var.high_availability_mode)
    error_message = "High availability mode must be Disabled or ZoneRedundant."
  }
}

variable "private_subnet_id" {
  description = "ID of the private subnet for database delegation"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.private_subnet_id))
    error_message = "Subnet ID must be a valid Azure resource ID."
  }
}

variable "virtual_network_id" {
  description = "ID of the virtual network for private DNS zone link"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.virtual_network_id))
    error_message = "Virtual network ID must be a valid Azure resource ID."
  }
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for database"
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
