# Redis Module - Input Variables

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

variable "project_name" {
  description = "Project name for naming resources"
  type        = string

  validation {
    condition     = length(var.project_name) <= 20 && can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must be lowercase alphanumeric with hyphens, max 20 characters."
  }
}

variable "redis_sku_name" {
  description = "SKU name for Redis Cache (Basic, Standard, Premium)"
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.redis_sku_name)
    error_message = "SKU name must be Basic, Standard, or Premium."
  }
}

variable "redis_family" {
  description = "Redis family (C for Basic/Standard, P for Premium)"
  type        = string
  default     = "P"

  validation {
    condition     = contains(["C", "P"], var.redis_family)
    error_message = "Redis family must be C or P."
  }
}

variable "redis_capacity" {
  description = "Redis cache capacity (0-6 for Premium)"
  type        = number
  default     = 1

  validation {
    condition     = var.redis_capacity >= 0 && var.redis_capacity <= 6
    error_message = "Redis capacity must be between 0 and 6."
  }
}

variable "private_subnet_id" {
  description = "ID of the private subnet for Redis private endpoint"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.private_subnet_id))
    error_message = "Subnet ID must be a valid Azure resource ID."
  }
}

variable "management_subnet_id" {
  description = "The ID of the subnet for the Private VM"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.management_subnet_id))
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
  description = "Enable diagnostic settings for Redis"
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
