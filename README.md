# Azure AKS Web Application Infrastructure

## Project Overview

This Terraform project provisions a production-grade, highly secure Azure infrastructure for hosting a web application using Azure Kubernetes Service (AKS). The setup emphasizes security, scalability, high availability, and network isolation through private endpoints and Virtual Network integration.

---

## Architecture Diagram

```text
┌─────────────────────────────────────────────────────────────────────┐
│                         Azure Virtual Network (VNet)                 │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Public Subnet (Application Gateway / Bastion)               │   │
│  │                                                               │   │
│  │    ┌─────────────────┐        ┌────────────────┐            │   │
│  │    │ Application     │        │ Bastion Host   │            │   │
│  │    │ Gateway + WAF   │        │ (Private VM)   │            │   │
│  │    └────────┬────────┘        └────────────────┘            │   │
│  └─────────────┼────────────────────────────────────────────────┘   │
│                │                                                     │
│  ┌─────────────┼────────────────────────────────────────────────┐   │
│  │  Private Subnet (AKS & Services)                             │   │
│  │                                                               │   │
│  │    ┌─────────────────┐        ┌────────────────┐            │   │
│  │    │ AKS Cluster     │        │ Internal LB    │            │   │
│  │    │ (Private)       │◄──────►│ (Traffic Map)  │            │   │
│  │    └────────┬────────┘        └────────┬───────┘            │   │
│  │             │                          │                    │   │
│  │    ┌────────┴──────────┬───────────────┘                    │   │
│  │    │                   │                                    │   │
│  │  [Private Endpoints]                                        │   │
│  │    │                   │                                    │   │
│  │    ▼                   ▼                                    │   │
│  │  ┌──────────┐    ┌──────────────────┐                      │   │
│  │  │ SQL DB   │    │ Storage Account  │                      │   │
│  │  │ (Flex)   │    │ + Blob (Logs)    │                      │   │
│  │  └──────────┘    └──────────────────┘                      │   │
│  │                                                               │   │
│  │  ┌──────────────────┐        ┌──────────────────┐           │   │
│  │  │ Redis Cache      │        │ NAT Gateway      │           │   │
│  │  │ (Private)        │        │ (Outbound)       │           │   │
│  │  └──────────────────┘        └──────────────────┘           │   │
│  └───────────────────────────────────────────────────────────┬──┘   │
│                                                                │      │
└────────────────────────────────────────────┬───────────────────────┘
                                             │
                                    ┌────────▼─────────┐
                                    │   Internet (for   │
                                    │   outbound only)  │
                                    └───────────────────┘
```

---

## Architecture Purpose & Benefits

### 1. **Security**

- **Network Isolation**: All services deployed in private subnets; only App Gateway exposed publicly
- **Private Endpoints**: All Azure services (SQL DB, Storage, Redis) accessible only through private network
- **Web Application Firewall**: Protects against common web exploits
- **Bastion Host**: Secure RDP/SSH access to VMs without public IPs
- **NSG Rules**: Strict ingress/egress rules on all subnets

### 2. **High Availability**

- **AKS Multi-Node Pools**: Ensures application availability
- **Application Gateway**: Load balancing across AKS nodes
- **Internal Load Balancer**: Maps traffic between App Gateway and AKS services
- **Azure SQL Flexible Server**: Built-in redundancy and failover
- **Redis Cache**: Caching layer for improved performance

### 3. **Scalability**

- **AKS Auto-scaling**: Horizontal Pod Autoscaler (HPA) for workloads
- **Node Auto-scaling**: Vertical scaling based on demand
- **Managed Services**: Serverless components scale automatically

### 4. **Compliance & Data Protection**

- **Encryption in Transit**: TLS/SSL enforced
- **Encryption at Rest**: All data encrypted using Azure-managed or customer-managed keys
- **Audit Logging**: All activities logged to Storage Account
- **Private Network**: HIPAA, PCI-DSS compliant by design

### 5. **Cost Optimization**

- **NAT Gateway**: Single outbound IP for AKS, reduced egress costs
- **Private Endpoints**: No additional charges vs public endpoints
- **Managed Services**: Reduced operational overhead

---

## Component Descriptions

### **Azure Virtual Network (VNet)**

- **CIDR**: 10.0.0.0/16 (customizable)
- **Purpose**: Contains all resources in isolated network environment
- **Subnets**:
  - **Public Subnet**: App Gateway, Bastion (10.0.1.0/24)
  - **Private Subnet**: AKS, Services, DBs (10.0.2.0/24)

### **Application Gateway**

- **Tier**: Standard v2 (highly available)
- **WAF**: OWASP Top 10 protection
- **Backend**: Internal Load Balancer (not direct to AKS)
- **Routing**: Path-based, host-based, multi-site routing rules
- **SSL/TLS**: Managed certificates

### **Web Application Firewall (WAF)**

- **Protection**: OWASP Core Rule Set
- **Mode**: Detection/Prevention
- **Custom Rules**: Can add IP whitelisting, rate limiting, geo-blocking

### **Azure Kubernetes Service (AKS)**

- **Network Plugin**: Azure CNI in private network
- **Cluster Type**: Private (no public API endpoint)
- **API Access**: Via private endpoint only
- **Default Node Pool**: 3 nodes, Standard_B2s
- **Node OS Disk**: Encrypted with platform-managed key

### **Internal Load Balancer**

- **Purpose**: Maps traffic from App Gateway to AKS services
- **Type**: Layer 4 (TCP/UDP)
- **Placement**: Private subnet
- **Backend Pools**: AKS nodes/services

### **Azure SQL Flexible Server**

- **Tier**: Standard (Burstable), configurable to Premium
- **Backup**: Geo-redundant backup (7-35 days)
- **Encryption**: TLS 1.2+, at-rest encryption
- **Private Endpoint**: Access only from VNet
- **Network**: No public IP

### **Azure Storage Account**

- **Tier**: Standard (Hot/Cool options)
- **Purpose**: Store application logs and backups
- **Access**: Private endpoint only
- **Encryption**: SSE (Server-Side Encryption)
- **Blob Container**: "logs", "backups"

### **Azure Cache for Redis**

- **Tier**: Standard/Premium (customizable)
- **Purpose**: Session storage, caching, real-time data
- **Clustering**: Optional cluster mode
- **Persistence**: RDB snapshots
- **Private Endpoint**: Access from VNet only

### **Private VM (Bastion Host)**

- **OS**: Windows Server 2022 or Linux (customizable)
- **Size**: Standard_B2s
- **Network**: Public subnet (for Bastion access)
- **Purpose**: Secure admin access point
- **No Public IP**: Uses Bastion service for secure connection

### **Azure Bastion**

- **Tier**: Standard
- **Access**: Browser-based RDP/SSH
- **Security**: No public IP exposure for managed VM
- **Network**: Deployed in public subnet

### **NAT Gateway**

- **Tier**: Standard
- **Purpose**: Outbound internet access for AKS with single public IP
- **Benefits**: Predictable outbound IP for firewall rules
- **Placement**: Associated with private subnet

### **Network Security Groups (NSGs)**

- **Public Subnet NSG**: Allows inbound 80/443 (App Gateway), RDP/SSH (Bastion)
- **Private Subnet NSG**: Allows traffic only from App Gateway, inter-service communication
- **Deny all**: Default deny policy with allow exceptions

### **Private Endpoints**

- **SQL Database**: Private endpoint in private subnet
- **Storage Account**: Private endpoint in private subnet
- **Redis Cache**: Private endpoint in private subnet
- **DNS**: Private DNS zones for seamless resolution
- **Network Interface**: NIC attached to each endpoint

---

## Data Flow

1. **User Request** → Internet → APP Gateway (Public IP) with WAF filtering
2. **Filtered Traffic** → Internal Load Balancer → AKS Service
3. **Application Logic** → Uses services via private endpoints:
   - SQL Database (for persistent data)
   - Redis Cache (for session/cache data)
   - Storage Account (for logs)
4. **Outbound Requests** → NAT Gateway → Internet (single public IP)
5. **Admin Access** → Bastion Service → Private VM RDP/SSH

---

## Security Considerations

### Network Security

- ✅ All inter-service communication encrypted (TLS 1.2+)
- ✅ No services publicly exposed except App Gateway
- ✅ Private endpoints prevent data exfiltration
- ✅ NSG rules follow principle of least privilege
- ✅ DDoS protection via App Gateway

### Identity & Access

- ✅ Managed Identity for AKS integration
- ✅ RBAC for Kubernetes clusters
- ✅ Azure AD integration for admin access
- ✅ Key Vault integration (can be added)

### Data Protection

- ✅ Encryption in transit (TLS)
- ✅ Encryption at rest (Platform-managed keys)
- ✅ Backup strategy (SQL: 7-35 days, Storage: LRS)
- ✅ Audit logs to Storage Account

---

## Deployment Methods

This project can be deployed via:

1. **Terraform CLI** (IaC approach)
2. **Azure Portal** (GUI approach)
3. **Azure CLI** (Scripted approach)

---

## Modular File Structure

```text
terraform/vnet/
│
├── 📄 Root Orchestration (Clean coordination)
│   ├── providers.tf           # Provider versions & auth (1.3K)
│   ├── main.tf                # Module instantiation (12K)
│   ├── variables.tf           # 70+ input variables (22K)
│   ├── outputs.tf             # Aggregated outputs (11K)
│   └── terraform.tfvars.example  # Example variable values
│
├── 📦 modules/                # Self-contained, reusable modules
│   │
│   ├── networking/            # VNet, Subnets, NSGs, NAT
│   │   ├── main.tf            # Resource definitions
│   │   ├── variables.tf       # Module inputs
│   │   └── outputs.tf         # Module outputs
│   │
│   ├── security/              # Key Vault, identities, RBAC
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── monitoring/            # Log Analytics, alerts
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── storage/               # Storage account, containers
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── database/              # PostgreSQL Flexible Server
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── redis/                 # Redis Cache (private)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── aks/                   # AKS cluster, node pools
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── app_gateway/           # Application Gateway + WAF
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── bastion/               # Bastion host, jump VM
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── load_balancer/         # Internal Load Balancer
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── 📚 Documentation
    ├── README.md              # This file (architecture overview)
    ├── QUICKSTART.md          # 5-minute quick start
    ├── START_HERE.md          # Project index & role-based guides
    ├── deployment_guide.md    # Step-by-step Terraform & GUI
    ├── KUBERNETES_EXAMPLES.md # K8s deployment patterns
    ├── PRODUCTION_BEST_PRACTICES.md  # Security & optimization
    ├── MANIFEST.md            # Complete project manifest
    └── Makefile               # Common operations
```

### Architecture Benefits of Modular Structure

✅ **Reusability**: Use modules in other projects  
✅ **Maintainability**: Changes isolated to specific modules  
✅ **Scalability**: Add/remove modules independently  
✅ **Testing**: Test modules in isolation  
✅ **Versioning**: Module versioning for reproducibility  
✅ **Dependency Management**: Explicit module dependencies in root `main.tf`

---

## Network Topology Summary

| Component | Subnet | IP Assignment | Accessibility |
| --------- | ------ | ------------- | ------------- |
| App Gateway | Public | Dynamic (Azure-managed) | Public (0.0.0.0/0) |
| Bastion | Public | Dynamic (Azure-managed) | Private via Bastion Service |
| Private VM | Public | Static | Only via Bastion |
| AKS Cluster | Private | 10.0.2.0/24 | Private Endpoint only |
| SQL DB | Private | Private Endpoint IP | Private Endpoint only |
| Storage Account | Private | Private Endpoint IP | Private Endpoint only |
| Redis Cache | Private | Private Endpoint IP | Private Endpoint only |
| NAT Gateway | Private | Public Static IP | Outbound only |

---

## Prerequisites

1. **Azure Subscription** with sufficient quota
2. **Terraform CLI** (v1.3+)
3. **Azure CLI** installed and authenticated
4. **kubectl** installed (for AKS management)
5. **Azure Storage Account** for Terraform state (backend)

---

## Quick Start

### Option 1: Terraform Deployment

```bash
cd terraform/vnet
terraform init
terraform plan
terraform apply
```

### Option 2: Azure Portal (See deployment_guide.md for detailed steps)

### Option 3: Azure CLI with Scripts

```bash
az login
./deploy.sh
```

---

## Customization Guide

### Change Region

Update `location` variable in `terraform.tfvars`

### Change VM Size

Update `vm_size` variable in `terraform.tfvars`

### Change AKS Version

Update `kubernetes_version` variable in `terraform.tfvars`

### Enable Additional Features

- Customer-managed encryption keys (Azure Key Vault)
- Azure Monitoring & Application Insights
- ArgoCD for GitOps deployment
- Istio for service mesh

---

## Cost Estimation

**Approximate Monthly Costs (US East Region):**

- AKS Cluster (3 nodes, B2s): $100
- Application Gateway: $30
- SQL Flexible Server (Burstable): $40
- Storage Account: $1
- Redis Cache (Standard): $15
- NAT Gateway: $30
- Bastion Service: $1
- **Total: ~$217/month** (varies by region and usage)

---

## Troubleshooting

### Common Issues

1. **Private Endpoint DNS Resolution**: Ensure private DNS zones are linked to VNet
2. **AKS Network Policy**: Configure CNI policies if no egress
3. **SQL Connection Timeouts**: Check NSG rules allow port 5432/3306
4. **App Gateway 502 Bad Gateway**: Verify internal LB backend health

See `deployment_guide.md` for detailed troubleshooting.

---

## Next Steps

1. Customize variables in `terraform.tfvars`
2. Review `terraform plan` output
3. Deploy infrastructure
4. Configure application deployments on AKS
5. Set up monitoring and alerting (optional)

---

## Support & Maintenance

- **Backup Schedule**: Daily automated backups for SQL
- **Patching**: AKS auto-upgrade enabled
- **Monitoring**: Send logs to Storage Account via diagnostic settings
- **Updates**: Regular Terraform module updates recommended
