# Networking Module - Input Variables

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name - used for naming conventions"
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR block for Virtual Network"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet (App Gateway, Bastion)"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet (AKS, Services)"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for outbound traffic"
  type        = bool
  default     = true
}

variable "nat_gateway_idle_timeout" {
  description = "NAT Gateway idle timeout in minutes"
  type        = number
  default     = 4
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
