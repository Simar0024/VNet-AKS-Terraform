# Azure Subscription & Project Details
variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name - used for naming conventions"
  type        = string
  default     = "webappaks"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-vnet-aks-app"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "centralindia"

  validation {
    condition     = contains(["centralindia", "eastus", "westus", "eastus2", "westus2", "centralus", "northeurope", "westeurope"], var.location)
    error_message = "Unsupported location. Use: eastus, westus, eastus2, westus2, centralus, northeurope, westeurope"
  }
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "Web Application AKS"
  }
}

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================

variable "vnet_cidr" {
  description = "CIDR block for Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet (App Gateway, Bastion)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet (AKS, Services)"
  type        = string
  default     = "10.0.2.0/24"
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

# ============================================================================
# AZURE KUBERNETES SERVICE (AKS) CONFIGURATION
# ============================================================================

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-app"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.34.4"
}

variable "aks_node_count" {
  description = "Number of nodes in AKS default pool"
  type        = number
  default     = 3

  validation {
    condition     = var.aks_node_count >= 1 && var.aks_node_count <= 100
    error_message = "Node count must be between 1 and 100."
  }
}

variable "aks_node_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "aks_max_pods_per_node" {
  description = "Maximum number of pods per AKS node"
  type        = number
  default     = 110
}

variable "aks_enable_auto_scaling" {
  description = "Enable autoscaling for AKS node pools"
  type        = bool
  default     = true
}

variable "aks_min_node_count" {
  description = "Minimum node count for autoscaling"
  type        = number
  default     = 2
}

variable "aks_max_node_count" {
  description = "Maximum node count for autoscaling"
  type        = number
  default     = 10
}

variable "aks_network_plugin" {
  description = "Network plugin for AKS (azure or kubenet)"
  type        = string
  default     = "azure"
}

variable "aks_network_policy" {
  description = "Network policy for AKS (azure or calico)"
  type        = string
  default     = "azure"
}

variable "aks_enable_rbac" {
  description = "Enable RBAC for AKS"
  type        = bool
  default     = true
}

variable "aks_enable_private_cluster" {
  description = "Enable private AKS cluster"
  type        = bool
  default     = true
}

variable "aks_enable_http_application_routing" {
  description = "Enable HTTP application routing"
  type        = bool
  default     = false
}

variable "aks_sku_tier" {
  description = "AKS SKU tier (Free or Paid)"
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Paid"], var.aks_sku_tier)
    error_message = "AKS SKU tier must be Free or Paid."
  }
}

# ============================================================================
# APPLICATION GATEWAY & WAF CONFIGURATION
# ============================================================================

variable "app_gateway_name" {
  description = "Name of Application Gateway"
  type        = string
  default     = "appgw-app"
}

variable "app_gateway_sku" {
  description = "SKU of Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "app_gateway_capacity" {
  description = "Capacity of Application Gateway"
  type        = number
  default     = 2

  validation {
    condition     = var.app_gateway_capacity >= 1 && var.app_gateway_capacity <= 32
    error_message = "Capacity must be between 1 and 32."
  }
}

variable "waf_enabled" {
  description = "Enable Web Application Firewall"
  type        = bool
  default     = true
}

variable "waf_mode" {
  description = "WAF mode (Detection or Prevention)"
  type        = string
  default     = "Prevention"

  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "WAF mode must be Detection or Prevention."
  }
}

variable "app_gateway_sku_name" {
  description = "WAF SKU name"
  type        = string
  default     = "WAF_v2"
}

# ============================================================================
# DATABASE CONFIGURATION
# ============================================================================

variable "sql_server_name" {
  description = "Name of SQL Flexible Server"
  type        = string
  default     = "psql-app-server"
}

variable "sql_version" {
  description = "SQL Server version (12 for MySQL, 13-14 for PostgreSQL)"
  type        = string
  default     = "16"
}

variable "sql_admin_username" {
  description = "Administrator username for SQL Database"
  type        = string
  sensitive   = true
}

variable "sql_admin_password" {
  description = "Administrator password for SQL Database"
  type        = string
  sensitive   = true
}

variable "sql_database_name" {
  description = "Name of the database"
  type        = string
  default     = "appdb"
}

variable "sql_sku" {
  description = "SKU for SQL Flexible Server (e.g., B_Standard_B2s, D_Standard_D2s_v3)"
  type        = string
  default     = "B_Standard_B2s"
}

variable "sql_storage_mb" {
  description = "Storage size in MB for SQL Database"
  type        = number
  default     = 32768
}

variable "sql_backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 7

  validation {
    condition     = var.sql_backup_retention_days >= 7 && var.sql_backup_retention_days <= 35
    error_message = "Backup retention must be between 7 and 35 days."
  }
}

# ============================================================================
# STORAGE ACCOUNT CONFIGURATION
# ============================================================================

variable "storage_account_name" {
  description = "Name of Storage Account (must be globally unique, lowercase)"
  type        = string
  default     = "vnetaksapplogs01"
}

variable "storage_account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication" {
  description = "Replication type (LRS, GRS, RAGRS, ZRS)"
  type        = string
  default     = "GRS"
}

variable "storage_account_access_tier" {
  description = "Access tier for blob storage (Hot or Cool)"
  type        = string
  default     = "Hot"
}

# ============================================================================
# REDIS CACHE CONFIGURATION
# ============================================================================

variable "redis_cache_name" {
  description = "Name of Redis Cache"
  type        = string
  default     = "redis-app-cache"
}

variable "redis_capacity" {
  description = "Redis cache capacity (0-6 where 0=250MB, 1=1GB, etc.)"
  type        = number
  default     = 1

  validation {
    condition     = var.redis_capacity >= 0 && var.redis_capacity <= 6
    error_message = "Redis capacity must be between 0 and 6."
  }
}

variable "redis_family" {
  description = "Redis cache family (C for Standard/Premium, P for Premium)"
  type        = string
  default     = "C"
}

variable "redis_sku_name" {
  description = "Redis cache SKU (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
}

variable "redis_enable_non_ssl_port" {
  description = "Enable non-SSL port for Redis"
  type        = bool
  default     = false
}

variable "redis_minimum_tls_version" {
  description = "Minimum TLS version for Redis (1.0, 1.1, 1.2)"
  type        = string
  default     = "1.2"
}

# ============================================================================
# PRIVATE VM / BASTION CONFIGURATION
# ============================================================================

variable "bastion_vm_name" {
  description = "Name of Bastion VM"
  type        = string
  default     = "vm-bastion"
}

variable "bastion_vm_size" {
  description = "VM size for Bastion host"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "bastion_os_type" {
  description = "Operating system for Bastion VM (Windows or Linux)"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Windows", "Linux"], var.bastion_os_type)
    error_message = "OS type must be Windows or Linux."
  }
}

variable "bastion_image_publisher" {
  description = "Image publisher for Bastion VM"
  type        = string
  default     = "Canonical"
}

variable "bastion_image_offer" {
  description = "Image offer for Bastion VM"
  type        = string
  default     = "UbuntuServer"
}

variable "bastion_image_sku" {
  description = "Image SKU for Bastion VM"
  type        = string
  default     = "18.04-LTS"
}

variable "bastion_image_version" {
  description = "Image version for Bastion VM"
  type        = string
  default     = "latest"
}

variable "admin_username" {
  description = "Windows admin username for Bastion VM"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Windows admin password for Bastion VM"
  type        = string
  sensitive   = true
}

# ============================================================================
# AZURE BASTION CONFIGURATION
# ============================================================================

variable "bastion_service_name" {
  description = "Name of Azure Bastion service"
  type        = string
  default     = "bastion-app"
}

variable "bastion_sku" {
  description = "Azure Bastion SKU (Basic or Standard)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.bastion_sku)
    error_message = "Bastion SKU must be Basic or Standard."
  }
}

# ============================================================================
# INTERNAL LOAD BALANCER CONFIGURATION
# ============================================================================

variable "internal_lb_name" {
  description = "Name of Internal Load Balancer"
  type        = string
  default     = "ilb-app-gateway"
}

variable "internal_lb_sku" {
  description = "Internal LB SKU (Basic or Standard)"
  type        = string
  default     = "Standard"
}

# ============================================================================
# PRIVATE ENDPOINTS CONFIGURATION
# ============================================================================

variable "private_dns_zone_name_sql" {
  description = "Private DNS Zone name for SQL Database"
  type        = string
  default     = "privatelink.mysql.database.azure.com"
}

variable "private_dns_zone_name_storage" {
  description = "Private DNS Zone name for Storage Account"
  type        = string
  default     = "privatelink.blob.core.windows.net"
}

variable "private_dns_zone_name_redis" {
  description = "Private DNS Zone name for Redis Cache"
  type        = string
  default     = "privatelink.redis.cache.windows.net"
}

# ============================================================================
# MONITORING & LOGGING (OPTIONAL)
# ============================================================================

variable "enable_diagnostics" {
  description = "Enable diagnostic logging for resources"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
}

# ============================================================================
# SSL CERTIFICATE CONFIGURATION
# ============================================================================

variable "ssl_certificate_password" {
  description = "Password for SSL certificate (pfx format)"
  type        = string
  sensitive   = true
}

# ============================================================================
# MONITORING CONFIGURATION
# ============================================================================

variable "log_analytics_sku" {
  description = "SKU of the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "PerGB2018", "Premium", "Standalone"], var.log_analytics_sku)
    error_message = "SKU must be Free, PerGB2018, Premium, or Standalone."
  }
}

variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
  default     = "simar022netsmartz@gmail.com"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.alert_email))
    error_message = "Alert email must be a valid email address."
  }
}

variable "enable_metric_alerts" {
  description = "Enable metric alerts"
  type        = bool
  default     = true
}

# ============================================================================
# ADDITIONAL STORAGE CONFIGURATION
# ============================================================================

variable "storage_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "GRS"
}

variable "storage_access_tier" {
  description = "Storage account access tier"
  type        = string
  default     = "Hot"
}

variable "blob_delete_retention_days" {
  description = "Blob delete retention days"
  type        = number
  default     = 7
}

variable "container_soft_delete_retention_days" {
  description = "Container soft delete retention days"
  type        = number
  default     = 7
}

variable "enable_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = true
}

# ============================================================================
# DATABASE CONFIGURATION
# ============================================================================

variable "database_server_name" {
  description = "Database server name"
  type        = string
  default     = "psql-app-server"
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "database_admin_user" {
  description = "Database admin username"
  type        = string
  default     = "psqladmin"
}

variable "database_admin_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
  default     = "PsqlAdminP@ssw0rd123!"
}

variable "database_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"
}

variable "database_sku_name" {
  description = "Database SKU name"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "database_storage_mb" {
  description = "Database storage in MB"
  type        = number
  default     = 32768
}

variable "backup_retention_days" {
  description = "Backup retention days"
  type        = number
  default     = 7
}

variable "enable_geo_redundant_backup" {
  description = "Enable geo-redundant backup"
  type        = bool
  default     = true
}


# ============================================================================
# ADDITIONAL AKS CONFIGURATION
# ============================================================================

variable "dns_prefix" {
  description = "DNS prefix for AKS"
  type        = string
  default     = "webappaks"
}

variable "node_pool_default_count" {
  description = "Default node pool count"
  type        = number
  default     = 3
}

variable "node_pool_default_vm_size" {
  description = "Default node pool VM size"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "node_pool_min_count" {
  description = "Minimum node count"
  type        = number
  default     = 1
}

variable "node_pool_max_count" {
  description = "Maximum node count"
  type        = number
  default     = 10
}

variable "node_os_disk_size" {
  description = "Node OS disk size in GB"
  type        = number
  default     = 128
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["1", "3"]
}

variable "service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP"
  type        = string
  default     = "10.0.0.10"
}

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR"
  type        = string
  default     = "172.17.0.1/16"
}

variable "aad_admin_groups" {
  description = "AAD admin groups"
  type        = list(string)
  default     = []
}

variable "authorized_ip_ranges" {
  description = "Authorized IP ranges"
  type        = list(string)
  default     = []
}

variable "create_system_nodepool" {
  description = "Create system nodepool"
  type        = bool
  default     = true
}

variable "system_node_pool_count" {
  description = "System nodepool count"
  type        = number
  default     = 2
}

variable "system_node_pool_vm_size" {
  description = "System nodepool VM size"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "system_node_pool_min_count" {
  description = "System nodepool min count"
  type        = number
  default     = 1
}

variable "system_node_pool_max_count" {
  description = "System nodepool max count"
  type        = number
  default     = 5
}

variable "create_compute_nodepool" {
  description = "Create compute nodepool"
  type        = bool
  default     = true
}

variable "compute_node_pool_count" {
  description = "Compute nodepool count"
  type        = number
  default     = 2
}

variable "compute_node_pool_vm_size" {
  description = "Compute nodepool VM size"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "compute_node_pool_min_count" {
  description = "Compute nodepool min count"
  type        = number
  default     = 1
}

variable "compute_node_pool_max_count" {
  description = "Compute nodepool max count"
  type        = number
  default     = 10
}

# ============================================================================
# APPLICATION GATEWAY CONFIGURATION
# ============================================================================

variable "app_gateway_sku_tier" {
  description = "Application Gateway SKU tier"
  type        = string
  default     = "WAF_v2"
}

variable "app_gateway_private_ip" {
  description = "Application Gateway private IP"
  type        = string
  default     = "10.1.1.10"
}

variable "backend_pool_ip_addresses" {
  description = "Backend pool IP addresses"
  type        = list(string)
  default     = []
}

variable "ssl_certificate_data" {
  description = "SSL certificate data (base64)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "autoscale_min_capacity" {
  description = "Autoscale minimum capacity"
  type        = number
  default     = 2
}

variable "autoscale_max_capacity" {
  description = "Autoscale maximum capacity"
  type        = number
  default     = 5
}

# ============================================================================
# BASTION CONFIGURATION
# ============================================================================

variable "bastion_admin_user" {
  description = "Bastion admin username"
  type        = string
  default     = "azureuser"
}

variable "bastion_admin_ssh_key" {
  description = "Bastion admin SSH public key"
  type        = string
  sensitive   = true
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzLZZUOuUbUUVDh/mrnSGlUkOOYgmjistO7re+FYicFKPqYPMOJEArJ/C/ON8LGIqK0wL6pos+aXZNKTDmitUnrP9o0lTpneXVjseje8sTidEYCNz31LX+4QrLTLOrbXr96zSoOWn30chgSfNqkQ09+HkVYk4w2CtR5/5bX7zcUtU5qkoonFh448rJC4u4oD87uLZTDH/hMZBLtuWqrmKNXAVKpjr6iR4Yk4wiwZhFSJARG5v5sQb2JwSEzIb1PL8Tnh9t7CAHvsChpkhHuEs6QRJE/dUfpaZBnkFIpMk+HDOpEDCTc8SISL0CG1YNXabA0s/7zSgMUTylQGzMhOFa+nsdJsT0djNPZ/wG8wma57rOEUmGQPiA9/4ImRrmEp4FfQd2KYdgssYEg37bvCda/gC5u5bDn+4rEsuT9OuEkuqMi8WSdiVn/wVfsPM4WrJ21NN9GwSYIQAmkcGIxxVea/HwLSHVyPP08UIz8cRHdTKvXMpUAiwwa4i3vMl93yO5mK8yPeZzjkTgTanaFTazVRVVArsGvCMGlaNA7G9roIeDXcUzTFl8zYLsW0OFIgwmzRoe7wb02O4kPdY8GNNa4ZL2hfZ8uyXq0+XfxUeKc4v06Sx8oTK9nnv93k3VPHlVmmW92v9WrXvDnN7uKDaNgmlXwo+sIlytAhDaHNA51Q== simarjit@NTZ-LINUX-002"
}

variable "enable_vm_encryption" {
  description = "Enable VM disk encryption"
  type        = bool
  default     = true
}

# ============================================================================
# LOAD BALANCER CONFIGURATION
# ============================================================================

variable "load_balancer_name" {
  description = "Load balancer name"
  type        = string
  default     = "ilb-webappaks"
}

variable "load_balancer_private_ip" {
  description = "Load balancer private IP"
  type        = string
  default     = "10.2.1.10"
}

variable "health_probe_protocol" {
  description = "Health probe protocol"
  type        = string
  default     = "Tcp"
}

variable "health_probe_port" {
  description = "Health probe port"
  type        = number
  default     = 80
}

variable "health_probe_path" {
  description = "Health probe path"
  type        = string
  default     = "/"
}

variable "create_bastion_vm" {
  description = "Create Bastion VM"
  type        = bool
  default     = true
}
