# Load Balancer Module - Input Variables

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

variable "load_balancer_name" {
  description = "Name of the load balancer"
  type        = string

  validation {
    condition     = length(var.load_balancer_name) >= 1 && length(var.load_balancer_name) <= 80
    error_message = "Load balancer name must be 1-80 characters."
  }
}

variable "private_subnet_id" {
  description = "ID of the private subnet for internal load balancer"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.private_subnet_id))
    error_message = "Subnet ID must be a valid Azure resource ID."
  }
}

variable "lb_subnet_id" {
  type        = string
  description = "The Subnet ID where the Internal Load Balancer will reside"
}

variable "load_balancer_private_ip" {
  description = "Private IP address for the load balancer frontend"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", var.load_balancer_private_ip))
    error_message = "Private IP must be a valid IPv4 address."
  }
}

variable "health_probe_protocol" {
  description = "Protocol for health probe (Tcp, Http, Https)"
  type        = string
  default     = "Tcp"

  validation {
    condition     = contains(["Tcp", "Http", "Https"], var.health_probe_protocol)
    error_message = "Health probe protocol must be Tcp, Http, or Https."
  }
}

variable "health_probe_port" {
  description = "Port for health probe"
  type        = number
  default     = 80

  validation {
    condition     = var.health_probe_port > 0 && var.health_probe_port < 65536
    error_message = "Health probe port must be between 1 and 65535."
  }
}

variable "health_probe_path" {
  description = "Path for HTTP(s) health probe"
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/", var.health_probe_path))
    error_message = "Health probe path must start with /."
  }
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for load balancer"
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
