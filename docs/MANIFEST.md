# Azure AKS Infrastructure - Project Manifest

## Project Overview

**Name**: Azure Web Application AKS Infrastructure  
**Purpose**: Production-grade Azure AKS deployment with comprehensive security, networking, and service integration  
**Location**: `/home/simarjit/terraform/vnet`  
**Date Created**: April 3, 2026

---

## File Inventory & Purpose

### 📄 Documentation Files

#### 1. **README.md** (Comprehensive)

- **Purpose**: Main project documentation with architecture overview
- **Content**:
- Architecture diagram
- Component descriptions
- Purpose and benefits
- Network topology
- Data flow explanation
- Prerequisites and quick start
- **Audience**: Project owners, architects, new team members

#### 2. **QUICKSTART.md** (5-10 minute read)

- **Purpose**: Get started immediately with 5 commands
- **Content**:
- Fast deployment steps
- File organization
- Architecture components
- Security features overview
- Common operations
- Troubleshooting quick reference
- **Audience**: Developers, DevOps engineers

#### 3. **deployment_guide.md** (Detailed)

- **Purpose**: Step-by-step deployment via Terraform AND GUI
- **Content**:
- Prerequisites and installation
- Terraform deployment (7 steps)
- Azure Portal GUI deployment (13 phases)
- Post-deployment setup
- Verification and testing
- Comprehensive troubleshooting
- **Audience**: Operators, platform engineers

#### 4. **KUBERNETES_EXAMPLES.md** (Reference)

- **Purpose**: Real-world Kubernetes manifests
- **Content**:
- 10 deployment examples
- Database integration patterns
- Redis integration
- Storage integration
- Network policies
- Resource quotas
- Deployment instructions
- **Audience**: Application developers, DevOps engineers

#### 5. **PRODUCTION_BEST_PRACTICES.md** (Strategic)

- **Purpose**: Production readiness and optimization
- **Content**:
- Security best practices
- High availability patterns
- Disaster recovery strategies
- Performance optimization
- Cost optimization
- Monitoring setup
- Backup strategies
- Compliance guidance
- Troubleshooting patterns
- **Audience**: Security engineers, architects, operations teams

---

### 🏗️ Infrastructure as Code (Terraform)

Infrastructure is organized as a modular Terraform architecture with 10 independent, reusable modules orchestrated by clean root files.

#### Root Orchestration Files

| File | Purpose | Size |
| ---- | ------- | ---- |
| `providers.tf` | Provider versions & authentication | 1.3K |
| `main.tf` | Module instantiation & dependencies | 12K |
| `variables.tf` | 70+ root-level input variables | 22K |
| `outputs.tf` | Aggregated outputs from modules | 11K |

#### Module: Networking (`modules/networking/3 files`)

**Resources**:

- Virtual Network (10.0.0.0/16)
- Public Subnet (10.0.1.0/24) - App Gateway, Bastion
- Private Subnet (10.0.2.0/24) - AKS, services, databases
- Network Security Groups (2):
  - Public NSG: HTTP/HTTPS (80, 443), RDP (3389), SSH (22)
  - Private NSG: Internal communication only
- NAT Gateway: Outbound internet for private subnet
- Route Tables: Custom routing for private subnet

#### Module: Security (`modules/security/3 files`)

**Resources**:

- Azure Key Vault: Encryption keys, secrets
- 3 Managed Identities:
  - AKS cluster identity
  - Storage account identity
  - VM/System identity
- RBAC Role Assignments: Services to identities
- Access Policies: Key Vault permissions
- Encryption Sets: For disk encryption

#### Module: Monitoring (`modules/monitoring/3 files`)

**Resources**:

- Log Analytics Workspace: Central logging
- Application Insights: APM for applications
- Action Group: Alert notifications
- Metric Alerts: CPU, memory, network monitoring
- Diagnostic Settings: All resources log here
- Alert Rules: AKS node health, app performance

#### Module: Storage (`modules/storage/3 files`)

**Resources**:

- Storage Account (General Purpose v2, GRS):
  - Managed identity assigned
  - CMK + Infrastructure encryption
  - Network rules: Private only
  - Private Endpoint + Private DNS Zone
- Blob Containers: app-data, backups, logs
  - Versioning enabled
  - Soft delete enabled
  - Retention policies configured

#### Module: Database (`modules/database/3 files`)

**Resources**:

- PostgreSQL Flexible Server (v14):
  - SKU: B_Standard_B1ms (burstable)
  - Storage: 32GB auto-scaling
  - High Availability: Zone-redundant option
  - Backups: 7-day retention, geo-redundant
  - Private Endpoint + Private DNS Zone
  - Firewall Rules: Allow from private subnet
  - Monitoring: Slow query log, audit events

#### Module: Redis (`modules/redis/3 files`)

**Resources**:

- Azure Cache for Redis:
  - SKU: Premium, Capacity: 1GB
  - TLS/SSL enforcement
  - Maxmemory policy: allkeys-lru
  - Private Endpoint + Private DNS Zone
  - Managed Identity for access control
  - Network ACLs: VNet-only access

#### Module: AKS (`modules/aks/3 files`)

**Resources**:

- Kubernetes Cluster (v1.27+):
  - Network: Azure CNI, private cluster option
  - RBAC: Enabled with Azure AD integration
  - Outbound: NAT Gateway route
  - Monitoring: Log Analytics integration
- Default Node Pool: 3-10 nodes (Standard_D2s_v3)
- System Node Pool: 2 nodes (system workloads)
- Compute Node Pool: 2-10 nodes (computation jobs)
- Auto-scaling: Enabled for all pools
- Addons:
  - Key Vault Secrets Provider
  - OMS Agent
  - HTTP Application Routing (disabled)

#### Module: Application Gateway (`modules/app_gateway/3 files`)

**Resources**:

- Application Gateway (SKU: WAF_v2):
  - Public IP frontend
  - HTTPS listener (port 443)
  - Backend pool: Internal LB
  - HTTP settings, health probes
- WAF Policy:
  - OWASP 3.2 rules
  - Detection/Prevention modes
  - Request body inspection
  - Geo-blocking ready
- SSL/TLS: Certificate management
- Routing Rules: Path-based, host-based routing
- Auto-scaling: 2-10 capacity

#### Module: Bastion (`modules/bastion/3 files`)

**Resources**:

- Azure Bastion Service:
  - Browser-based RDP/SSH
  - Standard SKU
  - File upload/copy enabled
- Jump VM (Windows Server 2022 or Linux):
  - Private subnet (no public IP)
  - System-assigned MSI
  - Disk encryption: CMK enabled
  - Network Interface: Private NIC with NSG
  - Diagnostics: Audit logs enabled

#### Module: Load Balancer (`modules/load_balancer/3 files`)

**Resources**:

- Internal Load Balancer (Standard SKU):
  - Private frontend IP (10.0.2.x)
  - Backend pool: AKS nodes
  - Health probes: TCP/HTTP monitoring
  - Load Rules: HTTP (80), HTTPS (443)
  - Session persistence: IP-based
  - Diagnostic settings: Metrics enabled

---

### 🛠️ Utilities & Tools

#### Makefile

**Purpose**: Common Terraform and Azure operations
**Targets**:

- `make init` - Initialize Terraform
- `make plan` - Generate plan
- `make apply` - Apply configuration
- `make destroy` - Destroy resources
- `make validate` - Validate syntax
- `make fmt` - Format code
- `make clean` - Clean state files
- `make kubeconfig` - Get kubectl config
- `make test-sql` - Test SQL connection
- `make check-prerequisites` - Verify tools

---

## Resource Summary

### 🌐 Networking Resources

- 1 Virtual Network (VNet)
- 2 Subnets (Public/Private)
- 2 Network Security Groups
- 2 Public IPs (App Gateway, Bastion)
- 1 Public IP (NAT Gateway)
- 1 NAT Gateway
- 1 Route Table
- 3 Private DNS Zones

### 🏗️ Compute Resources

- 1 AKS Cluster (private)
  - 3 System nodes (B2s)
  - 3+ Application nodes (B2s, auto-scaling)
  - 2 Node pools
- 1 Bastion VM (Windows Server 2022)
- 1 Azure Bastion Service

### 💾 Data Resources

- 1 SQL Flexible Server (MySQL)
- 1 Database instance
- 1 Redis Cache
- 1 Storage Account + Containers

### 🔐 Security Resources

- 1 Key Vault
- 2 Encryption Keys
- 1 Disk Encryption Set
- 3 Managed Identities
- Multiple Role Assignments

### 📊 Monitoring Resources

- 1 Log Analytics Workspace
- Diagnostic Settings (all resources)
- Network Watcher
- Flow Logs (optional)
- Connection Monitors (optional)

### 🔄 Load Balancing Resources

- 1 Application Gateway (WAF_v2)
- 1 Internal Load Balancer
- Multiple backend pools
- Health probes

### 🔗 Private Connectivity

- 3 Private Endpoints (SQL, Storage, Redis)
- 3 Private DNS Zones
- Private DNS A records

---

## Deployment Scenarios

### 🚀 Scenario 1: Terraform CLI (Recommended)

1. Copy `terraform.tfvars.example` → `terraform.tfvars`
2. Update values (subscription, passwords, storage account)
3. `terraform init`
4. `terraform plan`
5. `terraform apply`

**Time**: 20-30 minutes  
**Prerequistes**: Terraform CLI, Azure CLI  
**Complexity**: Medium

### 🖱️ Scenario 2: Azure Portal (GUI)

1. Create Resource Group
2. Create VNet with subnets
3. Create NSGs with rules
4. Create AKS cluster
5. Create App Gateway & WAF
6. Create SQL Database
7. Create Redis Cache
8. Create Storage Account
9. Create VMs & Bastion
10. Create Load Balancer
11. Configure Private Endpoints

**Time**: 45-60 minutes  
**Prerequisites**: Azure Portal access  
**Complexity**: High (many manual steps)

### ⚠️ Scenario 3: Mix (Terraform Core + Manual Services)

1. Deploy infrastructure via Terraform
2. Configure services manually via Portal
3. Link components manually

**Time**: 30-40 minutes  
**Prerequisites**: Both  
**Complexity**: Medium-High

---

## Security Architecture

### Network Security

```text
Internet
  ↓→ [Public IP] Application Gateway (WAF)
  ↓
  ├→ [NSG Rules] Public Subnet
  ├→ [NSG Rules] Private Subnet
  └→ [NAT Gateway] Outbound
  
[Private Endpoint] SQL Database
[Private Endpoint] Redis Cache
[Private Endpoint] Storage Account
```

### Identity & Access

```text
Managed Identity: AKS
  ├→ Storage Blob Data Contributor
  ├→ Network Contributor
  └→ Key Vault Access

Managed Identity: Storage Encryption
  └→ Key Vault Key Operations

Managed Identity: Bastion VM
  └→ System Assigned
```

### Data Protection

```text
At Rest:
  - SQL: Platform-managed encryption
  - Redis: Default encryption
  - Storage: Customer-managed (CMK)
  - OS Disks: Customer-managed (CMK)
  - VM Disks: Customer-managed (CMK)

In Transit:
  - AKS API: TLS 1.2+
  - SQL: Require SSL
  - Redis: TLS 1.2+ enforced
  - Storage: HTTPS only
```

---

## Cost Breakdown

| Service | Count | Unit Cost | Monthly |
| ------- | ----- | --------- | ------- |
| AKS Nodes | 3 | $30 | $90 |
| App Gateway | 1 | $30 | $30 |
| SQL Database | 1 | $40 | $40 |
| Redis Cache | 1 | $15 | $15 |
| Storage Account | 1 | $1 | $1 |
| NAT Gateway | 1 | $30 | $30 |
| Bastion Service | 1 | $1 | $1 |
| Log Analytics | 1 | $10 | $10 |
| **Total** | | | **$217** |

---

## Configuration Hierarchy

```text
terraform.tfvars (Your custom values)
    ↓
variables.tf (Validation & defaults)
    ↓
main.tf (Core resources)
    ↓
vpc.tf (Networking)
    ↓
aks.tf (Kubernetes)
    ↓
app_gateway.tf (Load balancing)
    ↓
database.tf (Persistence)
    ↓
storage.tf (Object storage)
    ↓
redis.tf (Caching)
    ↓
private_vm.tf (Bastion)
    ↓
load_balancer.tf (Internal routing)
    ↓
networking.tf (Advanced)
    ↓
outputs.tf (Deployment info)
```

---

## Maintenance Schedule

### Daily

- Monitor CPU/Memory metrics
- Check pod health
- Review error logs

### Weekly

- Review costs
- Check security alerts
- Validate backups

### Monthly

- Update AKS version
- Review and rotate secrets
- Update Terraform provider

### Quarterly

- Security audit
- Capacity planning
- Cost optimization review

### Annually

- Disaster recovery drill
- Architecture review
- Compliance assessment

---

## Integration Points

### Third-Party Services

- **Azure DevOps** / **GitHub**: CI/CD pipelines
- **Azure Container Registry**: Container image storage
- **Azure Monitor**: Centralized monitoring
- **Azure Security Center**: Security posture
- **Azure Policy**: Governance and compliance

### On-Premises Connectivity (Optional)

- **VPN Gateway**: Site-to-site connectivity
- **ExpressRoute**: Direct network connection
- **Hybrid runbook workers**: Run automation tasks

### External Services (Optional)

- **Datadog**: Advanced monitoring
- **HashiCorp Vault**: Secrets management
- **Atlassian Jira**: Incident tracking

---

## Customization Guide

### Modify Network

Edit `variables.tf`:

```hcl
vnet_cidr = "192.168.0.0/16"
public_subnet_cidr = "192.168.1.0/24"
private_subnet_cidr = "192.168.2.0/24"
```

### Upgrade Kubernetes

Edit `terraform.tfvars`:

```hcl
kubernetes_version = "1.28"  # From 1.27
```

### Scale Nodes

Edit `terraform.tfvars`:

```hcl
aks_node_count = 5          # From 3
aks_max_node_count = 15     # From 10
```

### Change Database

Edit `database.tf`:

```hcl
# Change from MySQL to PostgreSQL
resource "azurerm_postgresql_flexible_server" ...
```

---

## Support & References

### Official Documentation

- [Azure AKS Docs](https://learn.microsoft.com/azure/aks/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/)
- [Azure CLI Reference](https://learn.microsoft.com/cli/azure/)

### Community Resources

- [Stack Overflow](https://stackoverflow.com/questions/tagged/azure-kubernetes-service)
- [Azure Forums](https://learn.microsoft.com/answers/topics/azure-kubernetes-service.html)
- [GitHub Issues](https://github.com/hashicorp/terraform-provider-azurerm/issues)

### Internal Documentation

- See `deployment_guide.md` for step-by-step instructions
- See `PRODUCTION_BEST_PRACTICES.md` for security and optimization
- See `KUBERNETES_EXAMPLES.md` for application deployment patterns

---

## Version History

**Version 1.0** (April 3, 2026)

- Initial complete infrastructure setup
- All 13 components configured
- Comprehensive documentation
- Production-ready architecture
- Terraform v1.3+ compatible
- Azure provider v3.0+ compatible

---

## Project Status

✅ **Complete** - Ready for deployment

All components are fully configured and tested. Follow the deployment guide to get started.

---

**Created**: April 3, 2026  
**Platform**: Azure (Cloud)  
**IaC Tool**: Terraform  
**Kubernetes**: AKS  
**Ready for**: Production deployment (with review)
