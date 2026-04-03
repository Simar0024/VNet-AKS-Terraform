# Modular Architecture Guide

## Overview

This Terraform infrastructure uses a **modular architecture** with 10 independent, reusable modules coordinated by clean root files. This approach provides:

- **Separation of Concerns**: Each module handles one logical component
- **Reusability**: Modules can be used in other projects
- **Maintainability**: Changes are isolated to specific modules
- **Scalability**: Easy to add, remove, or replace modules
- **Testing**: Modules can be tested independently

---

## Directory Structure

```text
terraform/vnet/
├── ROOT ORCHESTRATION (Coordinates modules)
│   ├── main.tf               # Module instantiation
│   ├── variables.tf          # Root input variables
│   ├── outputs.tf            # Aggregated outputs
│   ├── providers.tf          # Provider configuration
│   └── terraform.tfvars.example
│
├── MODULES (10 self-contained components)
│   ├── modules/networking/   # VNet, subnets, NSGs
│   ├── modules/security/     # Key Vault, identities
│   ├── modules/monitoring/   # Log Analytics, alerts
│   ├── modules/storage/      # Storage account
│   ├── modules/database/     # PostgreSQL
│   ├── modules/redis/        # Redis cache
│   ├── modules/aks/          # Kubernetes cluster
│   ├── modules/app_gateway/  # Application Gateway
│   ├── modules/bastion/      # Bastion host
│   └── modules/load_balancer/ # Internal LB
│
└── DOCUMENTATION
    ├── README.md
    ├── QUICKSTART.md
    ├── deployment_guide.md
    ├── KUBERNETES_EXAMPLES.md
    ├── PRODUCTION_BEST_PRACTICES.md
    ├── MANIFEST.md
    └── This file
```

---

## Module Dependencies

The modules have carefully managed dependencies to ensure proper creation order:

```text
┌─────────────────────────────────────────────────────────┐
│                    Root Orchestration                    │
│                   (main.tf, variables)                   │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
    ┌───▼──┐    ┌───▼──┐    ┌───▼──┐
    │Security│   │Monitor│   │Network│
    └───┬──┘    └───┬──┘    └───┬──┘
        │            │            │
        │            │            ├─────────────┐
        │            │            │             │
        │      ┌─────┴────┬───────▼──┐     ┌───▼──┐
        │      │             │          │    │Bastion│
        │      ▼             ▼          ▼    └┬─────┘
        ├──▶ Storage ─┐   AKS      App GW   │
        │             │   (multi-pool)       │
        ├──▶ Database ─┤                      │
        │             │                      │
        └──▶ Redis ────┤                      │
                       │                      │
                    Load Balancer ◄──────────┘
```

### Dependency Explanation

1. **Security Module**: Creates identities and Key Vault (used by all)
2. **Monitoring Module**: Creates Log Analytics (used by all)
3. **Networking Module**: Creates VNet and subnets (used by all)
4. **Storage Module**: Depends on security (for identities)
5. **Database Module**: Depends on networking (for private endpoint)
6. **Redis Module**: Depends on networking (for private endpoint)
7. **AKS Module**: Depends on networking + monitoring + storage
8. **App Gateway Module**: Depends on networking
9. **Bastion Module**: Depends on networking + security
10. **Load Balancer Module**: Depends on networking + AKS

---

## Module Specifications

### 1. Networking Module (`modules/networking/`)

**Purpose**: Foundation for all other resources  
**What it creates**:

- Virtual Network (10.0.0.0/16)
- Public Subnet (10.0.1.0/24)
- Private Subnet (10.0.2.0/24)
- Network Security Groups (2)
- NAT Gateway
- Route Tables

**Inputs Required**:

- `resource_group_name`, `location`
- `vnet_cidr`, `public_subnet_cidr`, `private_subnet_cidr`
- `enable_nat_gateway`

**Outputs Provided**:

- `vnet_id`, `vnet_name`
- `public_subnet_id`, `private_subnet_id`
- `public_nsg_id`, `private_nsg_id`
- `nat_gateway_id`, `nat_gateway_public_ip`

---

### 2. Security Module (`modules/security/`)

**Purpose**: Identity and encryption management  
**What it creates**:

- Azure Key Vault
- 3 Managed Identities (AKS, Storage, VM)
- Role Assignments
- Encryption Sets

**Inputs Required**:

- `resource_group_name`, `location`
- `key_vault_name`, `environment`

**Outputs Provided**:

- `key_vault_id`, `key_vault_uri`
- `aks_identity_id`, `storage_identity_id`
- `vm_identity_id`

---

### 3. Monitoring Module (`modules/monitoring/`)

**Purpose**: Centralized logging and alerting  
**What it creates**:

- Log Analytics Workspace
- Application Insights
- Action Group
- Metric Alerts
- Diagnostic Settings

**Inputs Required**:

- `resource_group_name`, `location`
- `log_analytics_sku`, `alert_email`

**Outputs Provided**:

- `log_analytics_workspace_id`
- `action_group_id`
- `app_insights_id`

---

### 4. Storage Module (`modules/storage/`)

**Purpose**: Data storage with encryption  
**What it creates**:

- Storage Account (GRS, CMK)
- Blob Containers (app-data, backups, logs)
- Private Endpoint + Private DNS Zone
- Network Rules

**Inputs Required**:

- `resource_group_name`, `location`
- `storage_account_name`, `storage_tier`
- `storage_managed_identity_id`
- `private_subnet_id`, `key_vault_id`
- `virtual_network_id`

**Outputs Provided**:

- `storage_account_id`, `storage_account_name`
- `blob_endpoint`
- `storage_primary_connection_string`

---

### 5. Database Module (`modules/database/`)

**Purpose**: PostgreSQL database server  
**What it creates**:

- PostgreSQL Flexible Server
- Database
- Private Endpoint + Private DNS Zone
- Firewall Rules

**Inputs Required**:

- `resource_group_name`, `location`
- `database_server_name`, `database_name`
- `database_admin_user`, `database_admin_password`
- `database_sku_name`, `database_version`
- `private_subnet_id`, `virtual_network_id`

**Outputs Provided**:

- `database_server_id`, `database_server_fqdn`
- `database_id`
- `connection_string`

---

### 6. Redis Module (`modules/redis/`)

**Purpose**: In-memory data store and cache  
**What it creates**:

- Azure Cache for Redis
- Private Endpoint + Private DNS Zone
- Network ACLs
- Managed Identity

**Inputs Required**:

- `resource_group_name`, `location`
- `redis_sku_name`, `redis_capacity`
- `private_subnet_id`, `virtual_network_id`

**Outputs Provided**:

- `redis_cache_id`, `redis_primary_access_key`
- `redis_hostname`, `redis_ssl_port`
- `connection_string`

---

### 7. AKS Module (`modules/aks/`)

**Purpose**: Kubernetes cluster orchestration  
**What it creates**:

- AKS Cluster (private)
- 3 Node Pools (system, default, compute)
- Monitoring Integration
- RBAC Configuration

**Inputs Required**:

- `resource_group_name`, `location`, `resource_group_id`
- `aks_cluster_name`, `kubernetes_version`
- `node_pool_default_vm_size`, `node_pool_default_count`
- `private_subnet_id`, `log_analytics_workspace_id`
- `aks_managed_identity_id`

**Outputs Provided**:

- `aks_cluster_id`, `aks_cluster_name`
- `kube_config` (base64 encoded)
- `kubernetes_cluster_version`
- `node_pool_ids`

---

### 8. Application Gateway Module (`modules/app_gateway/`)

**Purpose**: Web traffic routing and WAF  
**What it creates**:

- Application Gateway (WAF_v2)
- Public IP
- Backend Pools
- WAF Policy
- HTTPS Listeners

**Inputs Required**:

- `resource_group_name`, `location`
- `app_gateway_name`, `public_subnet_id`
- `backend_pool_ips` (or load balancer IP)

**Outputs Provided**:

- `app_gateway_id`
- `public_ip_address`
- `backend_address_pool_id`

---

### 9. Bastion Module (`modules/bastion/`)

**Purpose**: Secure remote access  
**What it creates**:

- Azure Bastion Service
- Jump VM (Windows/Linux)
- Private Network Interface
- Disk Encryption

**Inputs Required**:

- `resource_group_name`, `location`
- `bastion_vm_name`, `bastion_subnet_id`
- `bastion_admin_user`, `bastion_admin_ssh_key`

**Outputs Provided**:

- `bastion_id`, `bastion_public_ip`
- `vm_id`, `vm_private_ip`
- `vm_password` (if provided)

---

### 10. Load Balancer Module (`modules/load_balancer/`)

**Purpose**: Internal traffic distribution  
**What it creates**:

- Internal Load Balancer (Standard)
- Backend Address Pool
- Health Probes
- Load Balancing Rules

**Inputs Required**:

- `resource_group_name`, `location`
- `load_balancer_name`, `private_subnet_id`
- `backend_pool_ips` (or AKS node IPs)

**Outputs Provided**:

- `load_balancer_id`
- `load_balancer_private_ip`
- `backend_address_pool_id`

---

## How Root Orchestration Works

The root `main.tf` file instantiates all modules and passes variables:

```hcl
module "networking" {
  source = "./modules/networking"
  
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_cidr           = var.vnet_cidr
  # ... more variables
}

module "aks" {
  source = "./modules/aks"
  
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  private_subnet_id   = module.networking.private_subnet_id  # From networking module
  # ... more variables
}
```

This creates a "dependency chain" where:

1. Networking is created first (foundation)
2. Security is created (identities for all)
3. Monitoring is created (logging for all)
4. Storage/Database/Redis use networking outputs
5. AKS uses networking + security + monitoring
6. App Gateway and Load Balancer depend on networking
7. Bastion depends on networking + security

---

## Adding a New Module

To add a new module:

1. **Create module directory**:

   ```bash
   mkdir -p modules/my_module
   ```

2. **Create 3 files**:

   ```text
   modules/my_module/
   ├── main.tf       # Resource definitions
   ├── variables.tf  # Input variables
   └── outputs.tf    # Output values
   ```

3. **Define variables** in `variables.tf` with descriptions and types
4. **Create resources** in `main.tf` using variables
5. **Export outputs** in `outputs.tf` for use by other modules
6. **Add module call** in root `main.tf`:

   ```hcl
   module "my_module" {
     source = "./modules/my_module"
     # Pass variables
   }
   ```

7. **Add to root variables.tf** any new input variables needed

---

## Benefits of This Architecture

| Benefit | How It Works |
| ------- | ---------- |
| **Reusability** | Use `modules/networking` in other projects |
| **Testability** | Test each module independently |
| **Maintainability** | Changes are isolated to specific modules |
| **Scalability** | Duplicate modules for multiple instances |
| **CI/CD** | Easier to test and deploy individual modules |
| **Team Collaboration** | Different teams can work on different modules |
| **Documentation** | Each module is self-documenting |
| **Version Control** | Easy to tag and release module versions |

---

## Common Operations

### Plan with Module Details

```bash
terraform plan -out=tfplan
# Shows which module each resource belongs to
```

### Destroy Specific Module

```bash
# WARNING: Destroys all resources in the module
terraform destroy -target=module.storage
```

### Initialize Specific Module

```bash
# Download dependencies for one module
terraform get modules/networking
```

### Format All Modules

```bash
# Format code in all modules
terraform fmt -recursive
```

---

## Module File Sizes

| Module | Total Size | Components |
| ------ | ---------- | ---------- |
| networking | ~15KB | VNet, subnets, NSGs, routes |
| security | ~8KB | Key Vault, identities, RBAC |
| monitoring | ~12KB | Log Analytics, alerts, dashboards |
| storage | ~10KB | Storage account, containers, PE |
| database | ~13KB | PostgreSQL server, networking |
| redis | ~9KB | Redis cache, networking |
| aks | ~18KB | AKS cluster, node pools, addons |
| app_gateway | ~16KB | App Gateway, WAF, routing |
| bastion | ~12KB | Bastion service, VM, disk encryption |
| load_balancer | ~8KB | Internal LB, health probes, rules |
| **Root files** | ~60KB | main.tf, variables.tf, outputs.tf |
| **Total** | ~181KB | 30 files (10 modules × 3 + 4 root + docs) |

---

## Next Steps

- Read [README.md](README.md) for architecture overview
- Follow [QUICKSTART.md](QUICKSTART.md) for 5-minute deployment
- Check [deployment_guide.md](deployment_guide.md) for detailed steps
- Review [PRODUCTION_BEST_PRACTICES.md](PRODUCTION_BEST_PRACTICES.md) for security

---
