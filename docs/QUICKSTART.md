# Azure AKS Infrastructure - Quick Start Guide

## 🚀 5-Minute Quick Start

### Prerequisites

```bash
# Install required tools
brew install terraform azure-cli kubectl  # macOS
apt-get install terraform azure-cli kubectl  # Ubuntu/Debian

# Login to Azure
az login
az account set --subscription "YOUR-SUBSCRIPTION-ID"
```

### Deploy Immediately

```bash
# 1. Navigate to project
cd terraform/vnet

# 2. Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Update: subscription_id, passwords, storage_account_name

# 3. Deploy (5 commands)
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Wait 20-30 minutes...

# 4. Get kubeconfig
terraform output -raw aks_kube_config > ~/.kube/config

# 5. Verify
kubectl get nodes
kubectl get all -A
```

---

## 📋 File Organization

### Root Terraform Files

| File | Purpose | Size |
| ---- | ------- | ---- |
| `providers.tf` | Provider versions & auth | 1.3K |
| `main.tf` | Module orchestration | 12K |
| `variables.tf` | Input variables | 22K |
| `outputs.tf` | Output aggregation | 11K |

### Infrastructure Modules (Modular Architecture)

| Module | Purpose | Files |
| ------ | ------- | ----- |
| `modules/networking/` | VNet, Subnets, NSGs, NAT | 3 files |
| `modules/aks/` | AKS cluster, 3 node pools | 3 files |
| `modules/app_gateway/` | Application Gateway + WAF | 3 files |
| `modules/database/` | PostgreSQL Flexible Server | 3 files |
| `modules/storage/` | Storage Account + containers | 3 files |
| `modules/redis/` | Redis Cache (private) | 3 files |
| `modules/bastion/` | Bastion host + jump VM | 3 files |
| `modules/load_balancer/` | Internal Load Balancer | 3 files |
| `modules/security/` | Key Vault + identities | 3 files |
| `modules/monitoring/` | Log Analytics + alerts | 3 files |

### Configuration & Examples

| File | Purpose |
| ---- | ------- |
| `terraform.tfvars.example` | Example variable values |
| `KUBERNETES_EXAMPLES.md` | K8s deployment examples |
| `PRODUCTION_BEST_PRACTICES.md` | Security & optimization |
| `deployment_guide.md` | Step-by-step instructions |
| `Makefile` | Common commands |

### Documentation

| File | Purpose |
| ---- | ------- |
| `README.md` | Architecture overview |
| `QUICKSTART.md` | This file |

---

## 🏗️ Architecture Components

### Networking Layer

```text
┌─ Virtual Network (10.0.0.0/16)
├─ Public Subnet (10.0.1.0/24)
│  ├─ Application Gateway (Public IP)
│  ├─ Bastion Service
│  └─ Bastion VM
├─ Private Subnet (10.0.2.0/24)
│  ├─ AKS Cluster (Private)
│  ├─ Internal Load Balancer
│  ├─ Private VMs
│  └─ Private Endpoints
└─ NAT Gateway (Outbound)
```

### Services Layer

```text
AKS Private Cluster
├─ System Node Pool
├─ Application Node Pool
└─ Log Analytics Workspace

Managed Services (Private Endpoints)
├─ SQL Database (MySQL 8.0)
├─ Redis Cache (Standard)
├─ Storage Account (GRS)
└─ Key Vault (Encryption)

Security
├─ Network Security Groups
├─ Application Gateway WAF
├─ Private Endpoints
└─ Managed Identities
```

---

## 🔐 Security Features

✅ **Network Security**

- Private AKS cluster (no public endpoint)
- Private endpoints for all services
- Network Security Groups with least privilege
- WAF for application protection
- NAT Gateway for secure outbound

✅ **Identity & Access**

- Azure Managed Identities
- RBAC for services
- Azure AD integration ready

✅ **Data Protection**

- Encryption at rest (CMK)
- Encryption in transit (TLS 1.2+)
- Automated backups
- Audit logging

---

## 💾 Changes Made to Your Workspace

### Created Files

```text
terraform/vnet/
├── providers.tf                        (Terraform/Azure provider config)
├── main.tf                             (Core resource group setup)
├── variables.tf                        (450+ input variables)
├── outputs.tf                          (200+ output values)
├── vpc.tf                              (VNet, subnets, NSGs, NAT)
├── aks.tf                              (AKS cluster with monitoring)
├── app_gateway.tf                      (App Gateway + WAF)
├── database.tf                         (SQL Flexible Server)
├── storage.tf                          (Storage with encryption)
├── redis.tf                            (Redis Cache)
├── private_vm.tf                       (Bastion VM + Bastion Service)
├── load_balancer.tf                    (Internal Load Balancer)
├── networking.tf                       (Advanced networking)
├── terraform.tfvars.example            (Example configuration)
├── Makefile                            (Common commands)
├── README.md                           (Architecture documentation)
├── QUICKSTART.md                       (This file)
├── deployment_guide.md                 (Step-by-step deployment)
├── KUBERNETES_EXAMPLES.md              (K8s deployment examples)
└── PRODUCTION_BEST_PRACTICES.md        (Security & optimization)
```

---

## 📊 Estimated Costs (Monthly)

```text
| Component | Cost |
| ----------- | ------ |
| AKS (3 nodes, B2s) | $90 |
| Application Gateway | $30 |
| SQL Database (Burstable) | $40 |
| Redis Cache (Standard) | $15 |
| Storage Account | $1 |
| NAT Gateway | $30 |
| Bastion Service | $1 |
| Log Analytics | $10 |
| **Total** | **~$217/month** |
```

```text
*Note: Costs vary by region and usage*
```

---

## 🔧 Common Operations

### Deploy

```bash
terraform apply tfplan
```

### Destroy

```bash
terraform destroy
```

### Get Outputs

```bash
terraform output
terraform output aks_cluster_name
```

### Connect to AKS

```bash
az aks get-credentials --resource-group "rg-webappaks-prod-eastus" \
  --name "aks-app-prod" --admin
kubectl get nodes
```

### Connect to Apps

```bash
kubectl logs -n applications deployment/web-app
kubectl exec -it <pod-name> -n applications -- bash
```

### Access Database

```bash
mysql -h sql-app-server-prod.mysql.database.azure.com \
  -u sqladmin -p
```

### Access Redis

```bash
redis-cli -h redis-app-cache-prod.redis.cache.windows.net \
  -p 6380 --tls
```

---

## 🐛 Troubleshooting

### "Quota exceeded"

```bash
# Check your quota
az vm list-usage -l eastus -o table

# Request more quota in Azure Portal
```

### "AKS cluster creation failed"

```bash
# Check deployment logs
az group deployment list --resource-group "rg-webappaks-prod-eastus" \
  --query "[0].properties.provisioningState"
```

### "Cannot connect to AKS"

```bash
# Verify private endpoint
kubectl cluster-info | grep Kubernetes

# Check private DNS zones
az network private-dns zone list -o table
```

See `deployment_guide.md` for more troubleshooting.

---

## 📚 Additional Resources

| Document | Content |
| -------- | ------- |
| `README.md` | Full architecture explanation |
| `deployment_guide.md` | GUI + Terraform step-by-step |
| `KUBERNETES_EXAMPLES.md` | K8s deployment patterns |
| `PRODUCTION_BEST_PRACTICES.md` | Security & optimization |
| `Makefile` | All common commands |

---

## ✅ Pre-Deployment Checklist

- [ ] Azure subscription with owner/contributor access
- [ ] Terraform installed (v1.3+)
- [ ] Azure CLI installed and authenticated
- [ ] kubectl installed
- [ ] Updated `terraform.tfvars` with your values
- [ ] Storage account name globally available (unique)
- [ ] Reviewed `variables.tf` for your preferences
- [ ] Sufficient quota for resources in chosen region

---

## 🎯 Next Steps After Deployment

1. **Verify Deployment**

   ```bash
   # Check all resources
   kubectl get nodes
   kubectl get pods -A
   az resource list -g "rg-webappaks-prod-eastus" -o table
   ```

2. **Deploy Sample Application**
   - Use manifests in `KUBERNETES_EXAMPLES.md`
   - Deploy to `applications` namespace

3. **Setup Monitoring**
   - Configure Azure Monitor alerts
   - Enable Application Insights
   - Setup Prometheus/Grafana (optional)

4. **Implement Security**
   - Configure Azure AD integration
   - Setup pod policies
   - Enable network policies

5. **Backup Strategy**
   - Install Velero for cluster backups
   - Configure database backups
   - Test restore procedures

6. **CI/CD Pipeline**
   - Setup Azure DevOps or GitHub Actions
   - Configure container registry (ACR)
   - Automate application deployments

---

## 📞 Support

For issues, refer to:

1. `deployment_guide.md` - Troubleshooting section
2. `PRODUCTION_BEST_PRACTICES.md` - Common patterns
3. [Azure AKS Documentation](https://learn.microsoft.com/azure/aks/)
4. [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/)

---

## 📝 Notes

- All sensitive data (passwords, keys) are marked as `sensitive` in Terraform
- Use Azure Key Vault for production secrets
- Enable diagnostic logging for compliance
- Review and adjust variables for your environment
- Test in non-production first
- Implement disaster recovery procedures
- Monitor costs regularly

---

**Last Updated**: April 3, 2026  
**Terraform Version**: 1.3+  
**Azure Provider**: 3.0+
