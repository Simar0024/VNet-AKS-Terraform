# Application Gateway Module - Input Variables

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

variable "app_gateway_name" {
  description = "Name of the Application Gateway"
  type        = string

  validation {
    condition     = length(var.app_gateway_name) >= 1 && length(var.app_gateway_name) <= 80
    error_message = "Application Gateway name must be 1-80 characters."
  }
}

variable "app_gateway_sku_name" {
  description = "SKU name for Application Gateway"
  type        = string
  default     = "WAF_v2"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.app_gateway_sku_name)
    error_message = "SKU name must be Standard_v2 or WAF_v2."
  }
}

variable "app_gateway_sku_tier" {
  description = "SKU tier for Application Gateway"
  type        = string
  default     = "WAF_v2"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.app_gateway_sku_tier)
    error_message = "SKU tier must be Standard_v2 or WAF_v2."
  }
}

variable "app_gateway_capacity" {
  description = "Capacity of the Application Gateway"
  type        = number
  default     = 2

  validation {
    condition     = var.app_gateway_capacity >= 1 && var.app_gateway_capacity <= 10
    error_message = "Capacity must be between 1 and 10."
  }
}

variable "app_gateway_subnet_id" {
  description = "ID of the subnet for Application Gateway"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.app_gateway_subnet_id))
    error_message = "Subnet ID must be a valid Azure resource ID."
  }
}

variable "app_gateway_private_ip" {
  description = "Private IP address for Application Gateway"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", var.app_gateway_private_ip))
    error_message = "Private IP must be a valid IPv4 address."
  }
}

variable "backend_pool_ip_addresses" {
  description = "Backend pool IP addresses"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for ip in var.backend_pool_ip_addresses : can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", ip))
    ])
    error_message = "All backend pool IPs must be valid IPv4 addresses."
  }
}

variable "ssl_certificate_data" {
  description = "SSL certificate data (base64 encoded)"
  type        = string
  sensitive   = true
}

variable "ssl_certificate_password" {
  description = "SSL certificate password"
  type        = string
  sensitive   = true
}

variable "autoscale_min_capacity" {
  description = "Minimum capacity for autoscaling"
  type        = number
  default     = 2

  validation {
    condition     = var.autoscale_min_capacity >= 2 && var.autoscale_min_capacity <= 125
    error_message = "Minimum capacity must be between 2 and 125."
  }
}

variable "autoscale_max_capacity" {
  description = "Maximum capacity for autoscaling"
  type        = number
  default     = 10

  validation {
    condition     = var.autoscale_max_capacity >= var.autoscale_min_capacity && var.autoscale_max_capacity <= 125
    error_message = "Maximum capacity must be >= minimum and <= 125."
  }
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for Application Gateway"
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
