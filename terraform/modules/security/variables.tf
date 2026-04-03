# Security Module - Input Variables

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

variable "resource_group_id" {
  description = "ID of the resource group"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.resource_group_id))
    error_message = "Resource group ID must be a valid Azure resource ID."
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

variable "aks_cluster_name" {
  description = "AKS cluster name for managed identity naming"
  type        = string

  validation {
    condition     = length(var.aks_cluster_name) > 0
    error_message = "AKS cluster name cannot be empty."
  }
}

variable "bastion_vm_name" {
  description = "Bastion VM name for managed identity naming"
  type        = string

  validation {
    condition     = length(var.bastion_vm_name) > 0
    error_message = "Bastion VM name cannot be empty."
  }
}

variable "private_subnet_id" {
  description = "ID of private subnet for Key Vault network rules"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/", var.private_subnet_id))
    error_message = "Subnet ID must be a valid Azure resource ID."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
