# Production Best Practices for Azure AKS Infrastructure

## Table of Contents

1. [Security Best Practices](#security-best-practices)
2. [High Availability & Disaster Recovery](#high-availability--disaster-recovery)
3. [Performance Optimization](#performance-optimization)
4. [Cost Optimization](#cost-optimization)
5. [Monitoring & Observability](#monitoring--observability)
6. [Backup Strategy](#backup-strategy)
7. [Compliance & Governance](#compliance--governance)
8. [Troubleshooting Patterns](#troubleshooting-patterns)

---

## Security Best Practices

### 1. **Network Security**

✅ **Implemented in this setup:**

- Private AKS cluster (no public endpoint)
- Private endpoints for all services
- Network Security Groups with least privilege
- VNet isolation

✅ **Additional recommendations:**

```bash
# Enable Azure Firewall for centralized traffic filtering
az network firewall create \
  --name "fw-${environment}" \
  --resource-group "$RG" \
  --location eastus

# Create firewall rules
az network firewall network-rule create \
  --firewall-name "fw-${environment}" \
  --resource-group "$RG" \
  --collection-name "allow-outbound" \
  --name "dns-rule" \
  --protocol "UDP" \
  --source-addresses "10.0.0.0/8" \
  --destination-addresses "*" \
  --destination-ports "53" \
  --action "Allow"
```

### 2. **Identity & Access Management (IAM)**

✅ **Implemented:**

- Managed Identities for services
- RBAC for Kubernetes

✅ **Recommended additions:**

```bash
# 1. Integrate with Azure AD
az aks update \
  --name "aks-app-prod" \
  --resource-group "$RG" \
  --enable-aad \
  --aad-admin-group-object-ids "00000000-0000-0000-0000-000000000000"

# 2. Create service accounts for applications
kubectl create serviceaccount app-service \
  -n applications

# 3. Bind to Azure AD groups
kubectl create rolebinding app-admin \
  --clusterrole=admin \
  --serviceaccount=applications:app-service

# 4. Use Pod Identity or Workload Identity
kubectl apply -f - << EOF
apiVersion: aadpodidentity.k8s.io/v1
kind: AzureIdentity
metadata:
  name: app-identity
  namespace: applications
spec:
  type: 0
  resourceID: /subscriptions/.../resourcegroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/app-mi
  clientID: "00000000-0000-0000-0000-000000000000"
EOF
```

### 3. **Secrets Management**

✅ **Recommended setup:**

```bash
# Use Azure Key Vault instead of plain secrets
az keyvault create \
  --name "kv-app-prod" \
  --resource-group "$RG" \
  --location eastus

# Store database credentials
az keyvault secret set \
  --vault-name "kv-app-prod" \
  --name "db-connection-string" \
  --value "mysql://user:pass@host/db"

# Grant AKS permission
az role assignment create \
  --assignee $(az aks show -g "$RG" -n "aks-app-prod" --query "addonProfiles.aciConnectorLinux.identity.principalId" -o tsv) \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/.../resourceGroups/$RG/providers/Microsoft.KeyVault/vaults/kv-app-prod"

# Use SecretProvider class in Kubernetes
kubectl apply -f - << EOF
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: app-secrets
  namespace: applications
spec:
  provider: azure
  parameters:
    usePodIdentity: "true"
    keyvaultName: "kv-app-prod"
    cloudEnvCtype: "AzurePublicCloud"
    objects: |
      array:
        - |
          objectName: db-connection-string
          objectType: secret
          objectAlias: connectionstring
EOF
```

### 4. **Encryption**

✅ **Implemented:**

- TLS for all communications
- At-rest encryption for databases

✅ **Enhancements:**

```bash
# Enable transport layer security
# For AKS
az aks update \
  --name "aks-app-prod" \
  --resource-group "$RG" \
  --network-plugin azure

# For SQL Database - enforce TLS 1.2+
az mysql flexible-server parameter set \
  --resource-group "$RG" \
  --server-name "sql-app-server-prod" \
  --name "require_secure_transport" \
  --value "ON"

# For Redis - enforce SSL
az redis update \
  --name "redis-app-cache-prod" \
  --resource-group "$RG" \
  --enable-non-ssl-port false \
  --minimum-tls-version 1.2
```

### 5. **Compliance & Audit Logging**

✅ **Enable audit logging:**

```bash
# Enable Azure Activity Logs
az monitor log-profiles create \
  --name "default" \
  --location global \
  --locations global \
  --categories "Write" "Delete"

# Enable diagnostic logging for all resources
# This is configured via monitoring settings in variables

# Enable Azure Policy enforcement
az policy assignment create \
  --name "require-encryption" \
  --policy "062766f4-fcc4-4206-b906-67251f655dd0"
```

---

## High Availability & Disaster Recovery

### 1. **AKS Cluster HA**

✅ **Implemented:**

- Multi-node setup (default 3 nodes)
- Auto-scaling enabled
- System and Application node pools

✅ **Enhancements:**

```bash
# Add additional node pools for specific workloads
az aks nodepool add \
  --resource-group "$RG" \
  --cluster-name "aks-app-prod" \
  --name "gpu" \
  --node-count 1 \
  --node-vm-size "Standard_D4s_v3" \
  --labels workload=gpu \
  --taints gpu=true:NoSchedule

# Enable pod disruption budgets
kubectl apply -f - << EOF
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
  namespace: applications
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: web-app
EOF

# Enable cluster autoscaler
az aks update \
  --resource-group "$RG" \
  --name "aks-app-prod" \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 10
```

### 2. **Database HA & Backup**

✅ **Implemented:**

- 7-day backup retention
- Geo-redundant backup

✅ **Enhancements:**

```bash
# Enable automated backups with longer retention
az mysql flexible-server update \
  --resource-group "$RG" \
  --name "sql-app-server-prod" \
  --backup-retention 35 \
  --backup-interval "daily"

# Create point-in-time restore
az mysql flexible-server restore \
  --resource-group "$RG" \
  --server-name "sql-app-server-prod-restore" \
  --source-server "sql-app-server-prod" \
  --restore-time "2024-01-15T10:00:00Z"

# Enable binary logging for replication (optional)
az mysql flexible-server parameter set \
  --resource-group "$RG" \
  --server-name "sql-app-server-prod" \
  --name "binlog_format" \
  --value "ROW"
```

### 3. **Storage Account Replication**

✅ **Implemented:**

- GRS (Geo-Redundant Storage)

✅ **Add read-only secondary endpoint:**

```bash
# Storage account already configured with GRS
# Access read-only copy via secondary endpoint
STORAGE_ACCOUNT="stappalogsXXX"
SECONDARY_ENDPOINT=$(az storage account show \
  --name "$STORAGE_ACCOUNT" \
  --query "secondaryEndpoints.blob" -o tsv)

# Access read-only in case of primary failure
curl "$SECONDARY_ENDPOINT/logs"
```

### 4. **Redis Replication (Premium only)**

```hcl
# In terraform/vnet/redis.tf, upgrade to Premium for replication
variable "redis_sku_name" {
  description = "Redis cache SKU (Premium for replication)"
  type        = string
  default     = "Premium"  # Changed from Standard
}

# Add replication configuration
resource "azurerm_redis_cache" "main" {
  # ... existing config ...
  sku_name = "Premium"
  family   = "P"
  
  # Premium tier replication
  replicas_per_primary = 1  # 1:1 replication
}
```

---

## Performance Optimization

### 1. **AKS Performance Tuning**

```bash
# Optimize kubelet settings
az aks nodepool update \
  --resource-group "$RG" \
  --cluster-name "aks-app-prod" \
  --name "system" \
  --max-pods 110

# Enable pod autoscaling
kubectl apply -f - << EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
  namespace: applications
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
EOF

# Enable container insights for metrics
az aks enable-addons \
  --resource-group "$RG" \
  --name "aks-app-prod" \
  --addons monitoring
```

### 2. **Database Performance**

```bash
# Enable slow query logging
az mysql flexible-server parameter set \
  --resource-group "$RG" \
  --server-name "sql-app-server-prod" \
  --name "long_query_time" \
  --value "1"

# Create indexes on frequently queried columns
mysql -h "sql-app-server-prod.mysql.database.azure.com" \
  -u "sqladmin" -p "appdb" << EOF
CREATE INDEX idx_user_id ON users(id);
CREATE INDEX idx_order_date ON orders(order_date);
EOF

# Monitor query performance
az monitor metrics list-definitions \
  --resource "/subscriptions/.../resourceGroups/$RG/providers/Microsoft.DBforMySQL/flexibleServers/sql-app-server-prod"
```

### 3. **Redis Performance**

```bash
# Optimize Redis configuration
az redis update \
  --name "redis-app-cache-prod" \
  --resource-group "$RG" \
  --minimum-tls-version 1.2 \
  --enable-non-ssl-port false

# Monitor Redis metrics
kubectl apply -f - << EOF
apiVersion: v1
kind: Service
metadata:
  name: redis-exporter
  namespace: applications
spec:
  ports:
  - port: 9121
  selector:
    app: redis-exporter
EOF
```

### 4. **Application Gateway Optimization**

```bash
# Increase App Gateway capacity
az network application-gateway update \
  --name "appgw-app-prod" \
  --resource-group "$RG" \
  --capacity 4

# Enable WAF logging
az network application-gateway waf-config set \
  --enabled true \
  --firewall-mode "Prevention" \
  --resource-group "$RG" \
  --gateway-name "appgw-app-prod"
```

---

## Cost Optimization

### 1. **Right-sizing Resources**

```bash
# Review current usage
az monitor metrics list \
  --resource "/subscriptions/.../resourceGroups/$RG/providers/Microsoft.ContainerService/managedClusters/aks-app-prod" \
  --metric "node_cpu_usage_percentage" \
  --start-time "2024-01-01T00:00:00Z" \
  --end-time "2024-01-31T23:59:59Z"

# Right-size node pools if consistently underutilized
az aks nodepool update \
  --resource-group "$RG" \
  --cluster-name "aks-app-prod" \
  --name "app" \
  --min-count 1 \
  --max-count 5
```

### 2. **Azure Hybrid Benefit**

```bash
# If you have SQL Server licenses, use Azure Hybrid Benefit
# Update SQL Server SKU during creation:
az mysql flexible-server create \
  # ... parameters ...
  # Already using consumption-based pricing in the setup
```

### 3. **Reserved Instances**

```bash
# Purchase 1-year or 3-year reserved instances for predictable workloads
# Via Azure Portal: Reservations → Purchase

# For Kubernetes - use Azure Spot VMs for non-critical workloads
az aks nodepool add \
  --resource-group "$RG" \
  --cluster-name "aks-app-prod" \
  --name "spot" \
  --priority "Spot" \
  --eviction-policy "Delete" \
  --node-count 2 \
  --node-vm-size "Standard_B2s"
```

### 4. **Storage Optimization**

```bash
# Use Cool tier for infrequently accessed logs
az storage account update \
  --name "stappalogsXXX" \
  --resource-group "$RG" \
  --access-tier "Cool"

# Implement lifecycle management
az storage account management-policy create \
  --account-name "stappalogsXXX" \
  --policy '
  {
    "rules": [
      {
        "name": "archive-old-logs",
        "type": "Lifecycle",
        "definition": {
          "filters": {"blobTypes": ["blockBlob"], "prefixMatch": ["logs/"]},
          "actions": {
            "baseBlob": {"delete": {"daysAfterModificationGreaterThan": 90}},
            "snapshot": {"delete": {"daysAfterCreationGreaterThan": 30}}
          }
        }
      }
    ]
  }'
```

---

## Monitoring & Observability

### 1. **Azure Monitor Setup**

```bash
# Create action group for alerts
az monitor action-group create \
  --name "alerts-prod" \
  --resource-group "$RG"

# Add email notification
az monitor action-group update \
  --name "alerts-prod" \
  --resource-group "$RG" \
  --add-action email \
  --action-group-name "Email Admin" \
  --email-receiver "admin@example.com"

# Create metric alert for AKS CPU
az monitor metrics alert create \
  --name "aks-cpu-alert" \
  --resource-group "$RG" \
  --scopes "/subscriptions/.../providers/Microsoft.ContainerService/managedClusters/aks-app-prod" \
  --condition "avg node_cpu_usage_percentage > 80" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action "$AG_ID"
```

### 2. **Application Insights**

```bash
# Create Application Insights
az monitor app-insights component create \
  --app "ai-app-prod" \
  --resource-group "$RG" \
  --location eastus \
  --kind web

# Deploy Application Insights to AKS
kubectl apply -f - << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: appinsights-config
  namespace: applications
data:
  APPINSIGHTS_INSTRUMENTATION_KEY: "YOUR_INSTRUMENTATION_KEY"
EOF
```

### 3. **Log Analytics Queries**

```kusto
// Query AKS cluster logs
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CONTAINERSERVICE"
| where ResourceType == "managedClusters"
| summarize Log_Count = count() by bin(TimeGenerated, 5m)

// Query performance metrics
InsightsMetrics
| where Namespace == "Container"
| where Name in ("cpuUsagePercentage", "memoryRssBytes")
| summarize avg(Val) by bin(TimeGenerated, 1h), Name
```

### 4. **Kubernetes Monitoring**

```bash
# Install Prometheus for detailed metrics
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --create-namespace

# Install Grafana for visualization
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana \
  -n monitoring \
  --create-namespace

# Access Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80
# Default credentials: admin / prom-operator
```

---

## Backup Strategy

### 1. **AKS Cluster Backup**

```bash
# Install Velero for cluster backup
wget https://github.com/vmware-tanzu/velero/releases/download/v1.12.0/velero-v1.12.0-linux-amd64.tar.gz
tar -xvf velero-v1.12.0-linux-amd64.tar.gz

# Create storage account for backups
az storage account create \
  --name "velerobackups" \
  --resource-group "$RG" \
  --location eastus

# Setup Velero with Azure plugin
velero install \
  --secret-file ./credentials-velero \
  --use-volume-snapshots=false \
  --snapshot-location-config snapshotLocation=eastus
```

### 2. **Database Backups**

```bash
# Backup MySQL to Storage Account
mysqldump -h "sql-app-server-prod.mysql.database.azure.com" \
  -u "sqladmin" -p "appdb" | \
  az storage blob upload \
    --account-name "stappalogsXXX" \
    --container-name "backups" \
    --name "appdb-$(date +%Y%m%d-%H%M%S).sql"

# Schedule automated backups with SQL Server backup
az container create \
  --resource-group "$RG" \
  --name "db-backup-scheduler" \
  --image "mysql:latest" \
  --environment-variables DB_HOST="..." DB_USER="..."
```

### 3. **Application Data Backups**

```bash
# Backup Redis to Storage Account
redis-cli --rdb /tmp/dump.rdb
az storage blob upload \
  --account-name "stappalogsXXX" \
  --container-name "backups" \
  --file /tmp/dump.rdb \
  --name "redis-$(date +%Y%m%d-%H%M%S).rdb"
```

---

## Compliance & Governance

### 1. **Azure Policy & Governance**

```bash
# Define compliance initiative
az policy assignment create \
  --name "ensure-encryption" \
  --policy "6c112d20-c1dc-41df-a15c-1e19f27cd391" \
  --scope "/subscriptions/YOUR_SUBSCRIPTION_ID"

# Tag enforcement
az policy assignment create \
  --name "require-environment-tag" \
  --policy "41806450-6ab8-4f51-8f3e-f2f7562bfca2" \
  --scope "/subscriptions/YOUR_SUBSCRIPTION_ID"
```

### 2. **RBAC Configuration**

```bash
# Create custom role for developers
az role definition create --role-definition '{
  "Name": "AKS Developer",
  "Description": "Limited AKS access for developers",
  "Type": "CustomRole",
  "Permissions": [
    {
      "Actions": [
        "Microsoft.ContainerService/managedClusters/read",
        "Microsoft.ContainerService/managedClusters/listClusterUserCredential/action"
      ],
      "NotActions": []
    }
  ],
  "AssignableScopes": ["/subscriptions/YOUR_SUBSCRIPTION_ID"]
}'

# Assign to users/groups
az role assignment create \
  --role "AKS Developer" \
  --assignee "user@example.com" \
  --scope "/subscriptions/YOUR_SUBSCRIPTION_ID"
```

### 3. **Enable Azure Defender**

```bash
# Enable security monitoring
az security auto-provisioning-setting update \
  --auto-provision "On"

# Enable Azure Defender for containeres
az security pricing create \
  --name "ContainerRegistries" \
  --tier "Standard"
```

---

## Troubleshooting Patterns

### 1. **AKS Connectivity Issues**

```bash
# Check API server connectivity
kubectl cluster-info dump | grep -A5 "API Server"

# Verify private endpoint
az network private-endpoint show \
  --ids "/subscriptions/.../resourceGroups/$RG/providers/Microsoft.Network/privateEndpoints/aks-pe"

# Test DNS resolution
nslookup aks-app-prod.azmk8s.io
```

### 2. **Database Connection Troubleshooting**

```bash
# Check private endpoint connectivity
telnet sql-app-server-prod.mysql.database.azure.com 3306

# Verify NSG rules
az network nsg rule list \
  --nsg-name "nsg-private-prod" \
  --resource-group "$RG" \
  --query "[?destinationPortRange=='3306']"

# Test from AKS pod
kubectl run -it debug --image=ubuntu --restart=Never -- bash
mysql -h sql-app-server-prod.mysql.database.azure.com \
  -u sqladmin -p
```

### 3. **Storage Access Issues**

```bash
# Check storage account firewall
az storage account show \
  --name "stappalogsXXX" \
  --query "networkRulesBypassOptions"

# Verify private endpoint
az network private-endpoint show \
  --name "pe-storage-prod" \
  --resource-group "$RG"

# Test access from AKS
kubectl run -it debug --image=ubuntu --restart=Never -- bash
apt-get install azure-cli
az storage blob list --account-name "stappalogsXXX" --container-name "logs"
```

---

## Conclusion

This setup provides a solid foundation for production AKS deployments. Regularly review and update this configuration based on:

- Azure service updates
- Your organization's security policies
- Performance metrics and monitoring data
- Cost optimization opportunities
- Compliance requirements

**Next steps:**

1. Implement monitoring with Azure Monitor + Prometheus
2. Setup automated backups with Velero
3. Configure CI/CD pipeline for application deployment
4. Implement GitOps with ArgoCD
5. Establish incident response procedures
