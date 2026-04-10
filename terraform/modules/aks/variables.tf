# AKS Module - Input Variables

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

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string

  validation {
    condition     = length(var.aks_cluster_name) >= 1 && length(var.aks_cluster_name) <= 63 && can(regex("^[a-zA-Z0-9-]+$", var.aks_cluster_name))
    error_message = "Cluster name must be 1-63 alphanumeric and hyphens."
  }
}

variable "dns_prefix" {
  description = "DNS prefix for AKS cluster FQDN"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.dns_prefix))
    error_message = "DNS prefix must contain only alphanumeric and hyphens."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.34.4"

  validation {
    condition     = can(regex("^1\\.[0-9]{2}$", var.kubernetes_version))
    error_message = "Kubernetes version must be in format 1.XX."
  }
}

variable "node_pool_default_count" {
  description = "Default node pool initial node count"
  type        = number
  default     = 2

  validation {
    condition     = var.node_pool_default_count >= 1 && var.node_pool_default_count <= 1000
    error_message = "Node count must be between 1 and 1000."
  }
}

variable "node_pool_default_vm_size" {
  description = "Default node pool VM size"
  type        = string
  default     = "Standard_B2s"

  validation {
    condition     = can(regex("^Standard_", var.node_pool_default_vm_size))
    error_message = "VM size must be a valid Azure VM SKU."
  }
}

variable "node_pool_min_count" {
  description = "Minimum node count for autoscaling"
  type        = number
  default     = 1

  validation {
    condition     = var.node_pool_min_count >= 1
    error_message = "Minimum node count must be at least 1."
  }
}

variable "node_pool_max_count" {
  description = "Maximum node count for autoscaling"
  type        = number
  default     = 10

  validation {
    condition     = var.node_pool_max_count >= var.node_pool_min_count
    error_message = "Maximum node count must be >= minimum node count."
  }
}

variable "aks_enable_auto_scaling" {
  description = "Enable autoscaling for AKS node pools"
  type        = bool
  default     = true
}

variable "node_os_disk_size" {
  description = "OS disk size in GB"
  type        = number
  default     = 128

  validation {
    condition     = var.node_os_disk_size >= 30 && var.node_os_disk_size <= 1024
    error_message = "OS disk size must be between 30 and 1024 GB."
  }
}

variable "availability_zones" {
  description = "Availability zones for node pools"
  type        = list(string)
  default     = ["1", "3"]

  validation {
    condition = alltrue([
      for zone in var.availability_zones : contains(["1", "2", "3"], zone)
    ])
    error_message = "Availability zones must be 1, 2, or 3."
  }
}

variable "private_subnet_id" {
  description = "ID of the private subnet for AKS"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.private_subnet_id))
    error_message = "Subnet ID must be a valid Azure resource ID."
  }
}

variable "service_cidr" {
  description = "CIDR range for Kubernetes services"
  type        = string
  default     = "172.16.0.0/16"

  validation {
    condition     = can(cidrhost(var.service_cidr, 1))
    error_message = "Service CIDR must be a valid CIDR block."
  }
}

variable "dns_service_ip" {
  description = "IP for Kubernetes DNS service"
  type        = string
  default     = "172.16.0.10"

  validation {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", var.dns_service_ip))
    error_message = "DNS service IP must be a valid IPv4 address."
  }
}

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR"
  type        = string
  default     = "172.17.0.1/16"

  validation {
    condition     = can(cidrhost(var.docker_bridge_cidr, 1))
    error_message = "Docker bridge CIDR must be a valid CIDR block."
  }
}

variable "aks_managed_identity_resource_id" {
  description = "Resource ID of the AKS managed identity"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.aks_managed_identity_resource_id))
    error_message = "Managed identity resource ID must be a valid Azure resource ID."
  }
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for monitoring"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.log_analytics_workspace_id))
    error_message = "Log Analytics Workspace ID must be a valid Azure resource ID."
  }
}

variable "action_group_id" {
  description = "Action Group ID for alerts"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.action_group_id))
    error_message = "Action Group ID must be a valid Azure resource ID."
  }
}

variable "aad_admin_groups" {
  description = "Azure AD group object IDs for cluster admin access"
  type        = list(string)
  default     = ["c290c9ee-ffb3-4c5f-aa46-2314146a9fdb"]
}

variable "authorized_ip_ranges" {
  description = "Authorized IP ranges for API access"
  type        = list(string)
  default     = []
}

variable "create_system_nodepool" {
  description = "Create dedicated system node pool"
  type        = bool
  default     = true
}

variable "system_node_pool_count" {
  description = "System node pool initial count"
  type        = number
  default     = 2

  validation {
    condition     = var.system_node_pool_count >= 1
    error_message = "System node pool count must be at least 1."
  }
}

variable "system_node_pool_vm_size" {
  description = "System node pool VM size"
  type        = string
  default     = "Standard_B2s"

  validation {
    condition     = can(regex("^Standard_", var.system_node_pool_vm_size))
    error_message = "VM size must be a valid Azure VM SKU."
  }
}

variable "system_node_pool_min_count" {
  description = "System node pool minimum count"
  type        = number
  default     = 1
}

variable "system_node_pool_max_count" {
  description = "System node pool maximum count"
  type        = number
  default     = 5
}

variable "create_compute_nodepool" {
  description = "Create dedicated compute node pool"
  type        = bool
  default     = true
}

variable "compute_node_pool_count" {
  description = "Compute node pool initial count"
  type        = number
  default     = 1

  validation {
    condition     = var.compute_node_pool_count >= 0
    error_message = "Compute node pool count must be at least 0."
  }
}

variable "compute_node_pool_vm_size" {
  description = "Compute node pool VM size"
  type        = string
  default     = "Standard_B2s"

  validation {
    condition     = can(regex("^Standard_", var.compute_node_pool_vm_size))
    error_message = "VM size must be a valid Azure VM SKU."
  }
}

variable "compute_node_pool_min_count" {
  description = "Compute node pool minimum count"
  type        = number
  default     = 1
}

variable "compute_node_pool_max_count" {
  description = "Compute node pool maximum count"
  type        = number
  default     = 10
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for AKS"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "app_gateway_id" {
  description = "The ID of the Application Gateway for AGIC"
  type        = string
  default     = null
}