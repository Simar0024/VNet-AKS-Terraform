# Azure AKS Web Application - Deployment Guide

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Terraform Deployment](#terraform-deployment)
3. [Azure Portal GUI Deployment](#azure-portal-gui-deployment)
4. [Post-Deployment Setup](#post-deployment-setup)
5. [Verification & Testing](#verification--testing)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Common Requirements

- **Azure Subscription** with sufficient quota:
  - Compute: vCPU quotas for VMs and AKS nodes
  - Networking: VNet, Public IPs, Load Balancers
  - Database: Azure SQL Flexible Server
  - Cache: Azure Redis
  - Storage: Storage Account

### For Terraform Deployment

```bash
# Install Terraform (v1.3+)
curl https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installations
terraform version
az --version
kubectl version --client

# Authenticate with Azure
az login
az account set --subscription "YOUR-SUBSCRIPTION-ID"
```

### For GUI Deployment

- Azure Portal access (portal.azure.com)
- Owner or Contributor role on subscription
- Modern web browser

---

## Terraform Deployment

### Step 1: Initialize Terraform

```bash
# Navigate to the Terraform directory
cd terraform/vnet

# Initialize Terraform working directory
terraform init

# Output should show:
# - Downloading providers (azurerm, kubernetes, helm)
# - Downloading modules (10 modules from modules/ directory)
# - Backend initialized successfully

# Verify modules were detected
terraform get
# Output: Getting modules...
# - networking in modules/networking
# - aks in modules/aks
# ... (all 10 modules)
```

### Step 2: Create Terraform Variables File

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**Critical variables to update:**

```hcl
azure_subscription_id    = "YOUR-SUBSCRIPTION-ID"
sql_admin_password       = "STRONG-PASSWORD"  # 8+ chars, special chars, numbers
admin_password          = "STRONG-PASSWORD"   # for Bastion VM
storage_account_name    = "GLOBALLY-UNIQUE-NAME"  # lowercase, 3-24 chars
```

### Step 3: Validate Configuration

```bash
# Validate Terraform syntax
terraform validate

# Output should show:
# Success! The configuration is valid.
```

### Step 4: Plan Deployment

```bash
# Generate execution plan
terraform plan -out=tfplan

# Review the output:
# - Number of resources to be added
# - Resource details
# - Make sure everything looks correct

# Save plan for auditing (recommended for production)
terraform show tfplan > deployment_plan.txt
```

### Step 5: Apply Configuration

```bash
# Apply Terraform configuration (creates all resources)
terraform apply tfplan

# This will take 20-30 minutes to complete:
# - VNet and subnets: 1 min
# - AKS cluster: 15-20 mins (longest)
# - Databases and services: 5-10 mins

# Monitor progress in Azure Portal (optional):
# Resource Group > Deployments
```

### Step 6: Retrieve Outputs

```bash
# Get all outputs
terraform output

# Get specific outputs
terraform output aks_cluster_name
terraform output app_gateway_public_ip
terraform output internal_lb_private_ip

# Save outputs for later reference
terraform output -json > deployment_outputs.json
```

### Step 7: Configure kubectl Access

```bash
# Get kubeconfig file
az aks get-credentials \
  --resource-group "rg-webappaks-prod-eastus" \
  --name "aks-app-prod" \
  --admin

# Verify cluster connectivity
kubectl cluster-info
kubectl get nodes
kubectl get all -A
```

---

## Azure Portal GUI Deployment

### Phase 1: Create Resource Group

1. Go to [portal.azure.com](https://portal.azure.com)
2. Click **Create a resource**
3. Search for **Resource group**
4. Click **Create**
5. Fill in details:
   - Subscription: Select your subscription
   - Name: `rg-webappaks-prod-eastus`
   - Region: `East US`
6. Click **Review + Create** → **Create**
7. Wait for deployment to complete

### Phase 2: Create Virtual Network

1. In Resource Group, click **Create a resource**
2. Search for **Virtual Network**
3. Click **Create**
4. Fill in details:
   - Name: `vnet-webappaks-prod`
   - Address space: `10.0.0.0/16`
   - Region: `East US` (same as RG)
5. Click **Next: IP Addresses**
6. Create first subnet:
   - Name: `subnet-public-prod`
   - Address range: `10.0.1.0/24`
7. Click **Add**
8. Create second subnet:
   - Name: `subnet-private-prod`
   - Address range: `10.0.2.0/24`
9. Click **Review + Create** → **Create**

### Phase 3: Create Network Security Groups (NSGs)

#### Public NSG

1. Create NSG: `nsg-public-prod`
2. Add Inbound Rules:
   - HTTP (port 80) from Any
   - HTTPS (port 443) from Any
   - RDP (port 3389) from Any
   - SSH (port 22) from Any

#### Private NSG

1. Create NSG: `nsg-private-prod`
2. Add Inbound Rules:
   - From Public subnet (10.0.1.0/24) - Allow All
   - From Private subnet (10.0.2.0/24) - Allow All
   - SQL (port 3306) from Private subnet

### Phase 4: Create NAT Gateway

1. Search for **NAT Gateway**
2. Click **Create**
3. Fill in:
   - Name: `natgw-webappaks-prod`
   - Region: `East US`
   - Public IP: Create new `pip-natgw`
4. Click **Create**
5. After creation, associate with Private subnet:
   - Go to NAT Gateway → Subnets
   - Click **Associate subnet**
   - Select `substrate-private-prod`

### Phase 5: Create AKS Cluster

1. Search for **Kubernetes Services (AKS)**
2. Click **Create → Create a Kubernetes cluster**
3. **Basics Tab:**
   - Resource Group: Select your RG
   - Cluster Name: `aks-app-prod`
   - Region: `East US`
   - Kubernetes version: `1.27`
   - API server availability: **Private cluster** (Enable)
   - Node size: `Standard_B2s`
   - Scale method: **Autoscale** (Enable)
   - Min count: 2
   - Max count: 10

4. **Networking Tab:**
   - Network configuration: **Bring your own virtual network**
   - Virtual network: Select `vnet-webappaks-prod`
   - Cluster subnet: Select `subnet-private-prod`
   - Docker bridge address: `172.17.0.1/16`
   - Service CIDR: `10.1.0.0/16`
   - DNS service IP: `10.1.0.10`
   - Network plugin: **Azure CNI**
   - Network policy: **Azure**
   - Outbound type: **User-assigned NAT Gateway**
   - Associate with the NAT Gateway created earlier

5. **Integrations Tab:**
   - Container insights: **Enable**
   - Create new Log Analytics workspace

6. Review and **Create**

### Phase 6: Create Public IP for Application Gateway

1. Search for **Public IP addresses**
2. Click **Create**
3. Fill in:
   - Name: `pip-appgw`
   - SKU: `Standard`
   - Tier: `Regional`
4. Click **Create**

### Phase 7: Create Application Gateway with WAF

1. Search for **Application Gateway**
2. Click **Create**
3. **Basics:**
   - Name: `appgw-app-prod`
   - Tier: **WAF_v2** (includes WAF)
   - Capacity: 2

4. **Frontends:**
   - Frontend IP configuration: **Public**
   - Select the public IP created above

5. **Backends:**
   - Backend pool: Create new `backend-ilb`
   - Target type: **IP address or FQDN**

6. **HTTP Settings:**
   - Create HTTP settings: Port 80, Protocol HTTP

7. **Rules:**
   - Create routing rule from HTTP listener to backend pool

8. **WAF Configuration:**
   - Mode: **Prevention**
   - Rule set: **OWASP 3.1**

### Phase 8: Create SQL Flexible Server

1. Search for **Azure Database for MySQL - Flexible Server**
2. Click **Create**
3. **Basics:**
   - Server name: `sql-app-server-prod`
   - Region: `East US`
   - MySQL version: `8.0`
   - Compute + Storage: **B_Standard_B2s**

4. **Networking:**
   - Connectivity method: **Private endpoint**
   - Virtual Network: Select your VNet
   - Subnet: Select private subnet

5. **Create**

### Phase 9: Create Redis Cache

1. Search for **Azure Cache for Redis**
2. Click **Create**
3. Fill in:
   - Name: `redis-app-cache-prod`
   - Pricing tier: **Standard C1**
   - Cluster: Disabled (for basic setup)

4. **Networking:**
   - Connectivity method: **Private endpoint**
   - Virtual Network: Select your VNet
   - Subnet: Select private subnet

5. Click **Create**

### Phase 10: Create Storage Account

1. Search for **Storage accounts**
2. Click **Create**
3. **Basics:**
   - Name: Must be globally unique (e.g., `stappalogsXXX`)
   - Account kind: **StorageV2**
   - Replication: **GRS** (Geo-redundant)
   - Access tier: **Hot**

4. **Networking:**
   - Default: Allow all access (can restrict after)

5. **Create**

### Phase 11: Create Private VM for Bastion

1. Search for **Virtual Machines**
2. Click **Create → Azure Virtual Machine**
3. **Basics:**
   - Name: `vm-bastion-prod`
   - Image: **Windows Server 2022 Datacenter**
   - Size: `Standard_B2s`
   - Username: `azureadmin`
   - Password: Strong password

4. **Networking:**
   - Virtual network: Select your VNet
   - Subnet: **Public subnet**
   - Public IP: **None** (will access via Bastion)
   - NSG: Attach public NSG

5. Click **Create**

### Phase 12: Create Azure Bastion Service

1. Search for **Bastions**
2. Click **Create**
3. Fill in:
   - Name: `bastion-app-prod`
   - Virtual Network: Select your VNet
   - Subnet: **bastion** (will be created)
   - Public IP: Create new

4. Click **Create**
5. This will add a new `/26` subnet automatically

### Phase 13: Create Internal Load Balancer

1. Search for **Load Balancer**
2. Click **Create**
3. **Basics:**
   - Name: `ilb-app-gateway-prod`
   - Type: **Internal**
   - SKU: **Standard**
   - Virtual network: Select your VNet
   - Subnet: Select private subnet

4. **Backend pools:**
   - Create: `backend-aks-nodes`
   - Virtual network: Select your VNet

5. **Health probes:**
   - Create: `probe-aks-tcp` (port 8080, interval 15s)

6. **Load balancing rules:**
   - HTTP (80 → 80)
   - HTTPS (443 → 443)
   - App traffic (8080 → 8080)

7. Click **Review + Create** → **Create**

---

## Post-Deployment Setup

### 1. Connect to Bastion VM

```bash
# Via Azure Portal
# Navigate to vm-bastion-prod
# Click "Bastion" → Connect
# Username: azureadmin
# Password: [your password]

# Or via Azure CLI
az bastion rdp --name bastion-app-prod \
  --resource-group rg-webappaks-prod-eastus \
  --target-resource-id <vm-resource-id>
```

### 2. Connect to AKS Cluster

```bash
# Get kubeconfig
az aks get-credentials \
  --resource-group "rg-webappaks-prod-eastus" \
  --name "aks-app-prod" \
  --admin

# Verify connectivity
kubectl cluster-info
kubectl get nodes
```

### 3. Create Application Namespaces

```bash
# Create namespace for applications
kubectl create namespace applications

# Create namespace for system services
kubectl create namespace system-services

# Verify
kubectl get namespaces
```

### 4. Deploy Sample Application

```bash
# Create a test deployment
kubectl create deployment test-app \
  --image=nginx:latest \
  --replicas=3 \
  -n applications

# Expose as service
kubectl expose deployment test-app \
  --port=80 \
  --target-port=80 \
  --type=LoadBalancer \
  -n applications

# Verify
kubectl get pods -n applications
kubectl get svc -n applications
```

### 5. Configure Application Gateway Backend

```bash
# Get Internal LB IP
az network lb show \
  --name ilb-app-gateway-prod \
  --resource-group rg-webappaks-prod-eastus \
  --query "frontendIpConfigurations[0].privateIpAddress"

# Note this IP and configure App Gateway backend with it
```

### 6. Setup Database Connection

```bash
# From Bastion VM, test SQL connection
# Download MySQL client or use SSMS

# Connection details from Terraform outputs
Hostname: sql-app-server-prod.mysql.database.azure.com
Database: appdb
Username: sqladmin
Port: 3306
```

### 7. Setup Redis Connection

```bash
# From Bastion VM, test Redis connection
redis-cli -h redis-app-cache-prod.redis.cache.windows.net \
  -p 6380 --tls

# Or from any VM with endpoint access
redis-cli --help
```

### 8. Configure Storage Account Access

```bash
# Grant AKS managed identity access to storage
az role assignment create \
  --assignee $(az aks show -g rg-webappaks-prod-eastus \
    -n aks-app-prod --query "identityprofile[0].principalid" -o tsv) \
  --role "Storage Blob Data Contributor" \
  --scope $(az storage account show \
    -g rg-webappaks-prod-eastus \
    -n stappalogsXXX --query id -o tsv)
```

---

## Verification & Testing

### 1. Network Connectivity Tests

```bash
# Test from Private subnet (AKS)
kubectl run -it --rm debug --image=ubuntu --restart=Never -- bash

# Inside the pod:
apt-get update && apt-get install -y curl mysql-client redis-tools

# Test SQL
mysql -h sql-app-server-prod.mysql.database.azure.com \
  -u sqladmin -p appdb

# Test Redis
redis-cli -h redis-app-cache-prod.redis.cache.windows.net \
  -p 6380 --tls ping

# Test Storage
curl https://stappalogsXXX.blob.core.windows.net/
```

### 2. Application Gateway Tests

```bash
# Get App Gateway public IP
APP_GW_IP=$(az network public-ip show \
  -g rg-webappaks-prod-eastus \
  -n pip-appgw --query "ipAddress" -o tsv)

# Test HTTP (should receive response)
curl http://$APP_GW_IP

# Test HTTPS (requires certificate)
curl https://$APP_GW_IP --insecure
```

### 3. Load Balancer Tests

```bash
# Check Internal LB status
az network lb show \
  --name ilb-app-gateway-prod \
  --resource-group rg-webappaks-prod-eastus \
  --query "backendAddressPools[0].backendIpConfigurations"
```

### 4. AKS Node Health

```bash
# Check node status
kubectl get nodes

# Check system pods
kubectl get pods -n system-services

# Check cluster info
kubectl cluster-info
kubectl top nodes
kubectl top pods -A
```

### 5. Database Health

```bash
# Check connection
az mysql flexible-server firewall-rule list \
  -g rg-webappaks-prod-eastus \
  -n sql-app-server-prod
```

---

## Troubleshooting

### Common Issues & Solutions

#### 1. **AKS Cluster Creation Failed**

**Error:** "VirtualMachine deployment failed"

```bash
# Check quota
az vm list-usage -l eastus -o table

# Increase quota in Azure Portal:
# Help + Support → New support request
# Issue type: Service and subscription limits (quotas)
# Quota type: Compute-VM (cores-vCPUs)
```

#### 2. **Private Endpoint DNS Resolution Failed**

**Error:** "Cannot resolve private endpoint DNS"

```bash
# Verify DNS zone links
az network private-dns zone virtual-network-link list \
  -g rg-webappaks-prod-eastus \
  -z privatelink.blob.core.windows.net

# Test from AKS pod
nslookup stappalogsXXX.blob.core.windows.net
```

#### 3. **Application Gateway 502 Bad Gateway**

**Error:** Service responding with 502 errors

```bash
# Check backend pool health
az network application-gateway address-pool list \
  -g rg-webappaks-prod-eastus \
  -n appgw-app-prod

# Verify Internal LB is properly configured
kubectl get svc -A
```

#### 4. **SQL Connection Timeout**

**Error:** "Could not connect to server"

```bash
# Verify NSG allows traffic
az network nsg rule list \
  -g rg-webappaks-prod-eastus \
  --nsg-name nsg-private-prod \
  -o table

# Test port from AKS
telnet sql-app-server-prod.mysql.database.azure.com 3306
```

#### 5. **NAT Gateway Not Allocating Public IP**

**Error:** "No public IP returned from NAT Gateway"

```bash
# Check NAT Gateway configuration
az network nat gateway show \
  -g rg-webappaks-prod-eastus \
  -n natgw-webappaks-prod

# Verify association with subnet
az network vnet subnet show \
  -g rg-webappaks-prod-eastus \
  -n subnet-private-prod \
  --vnet-name vnet-webappaks-prod \
  --query "natGateway"
```

#### 6. **Bastion Connection Failed**

**Error:** "Cannot connect to Bastion VM"

```bash
# Check Bastion status
az network bastion show \
  -g rg-webappaks-prod-eastus \
  -n bastion-app-prod

# Check Bastion subnet NSG
az network nsg rule list \
  -g rg-webappaks-prod-eastus \
  --nsg-name "AzureBastionSubnet-nsg" \
  -o table

# Ensure VM Network Interface security group allows RDP
```

### Debugging Commands

```bash
# Check all resources
az resource list -g rg-webappaks-prod-eastus -o table

# View activity logs
az monitor activity-log list \
  --resource-group rg-webappaks-prod-eastus \
  --max-events 50

# Check service health
az network service-endpoint list -l eastus

# Validate networking
az network vnet check-ip-address \
  -g rg-webappaks-prod-eastus \
  -n vnet-webappaks-prod \
  --ip-address "10.0.2.10"
```

---

## Next Steps

1. **Deploy Applications:**
   - Create Kubernetes manifests for your applications
   - Push images to Azure Container Registry (ACR)
   - Deploy via kubectl or GitOps (ArgoCD)

2. **Setup Monitoring:**
   - Configure Application Insights
   - Setup Azure Monitor alerts
   - Create dashboards

3. **Implement Security:**
   - Configure Azure AD integration for RBAC
   - Setup Pod Security Policies
   - Implement Network Policies

4. **Backup & Disaster Recovery:**
   - Configure SQL backups to Storage Account
   - Setup Velero for Kubernetes volumes
   - Implement geo-redundancy

5. **Cost Optimization:**
   - Review and adjust VM sizes
   - Implement pod autoscaling
   - Use spot instances for non-critical workloads

---

## Cleanup

### Remove All Resources (Terraform)

```bash
terraform destroy
```

### Remove All Resources (Azure CLI)

```bash
az group delete \
  --name rg-webappaks-prod-eastus \
  --yes --no-wait
```

---

## Support & References

- [Azure Kubernetes Service Documentation](https://learn.microsoft.com/en-us/azure/aks/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/reference-index)
- [kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)
