# Kubernetes Deployment Examples for AKS

This directory contains example Kubernetes manifests for deploying applications on the AKS cluster.

## Example 1: Simple Web Application with Internal Load Balancer

```yaml
# web-app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: applications
  labels:
    app: web-app
    version: v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
---
# Service with Internal Load Balancer
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
  namespace: applications
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  loadBalancerSourceRanges:
  - 10.0.0.0/8  # Allow only from VNet
```

## Example 2: Database Connection Configuration

```yaml
# db-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: database-credentials
  namespace: applications
type: Opaque
stringData:
  host: "sql-app-server-prod.mysql.database.azure.com"
  port: "3306"
  database: "appdb"
  username: "sqladmin"
  password: "YOUR_PASSWORD"  # Use Azure Key Vault in production

---
# db-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: database-config
  namespace: applications
data:
  DB_HOST: "sql-app-server-prod.mysql.database.azure.com"
  DB_PORT: "3306"
  DB_NAME: "appdb"
  DB_CHARSET: "utf8mb4"

---
# app-with-db.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-db
  namespace: applications
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app-with-db
  template:
    metadata:
      labels:
        app: app-with-db
    spec:
      containers:
      - name: app
        image: myapp:v1
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: database-config
              key: DB_HOST
        - name: DB_PORT
          valueFrom:
            configMapKeyRef:
              name: database-config
              key: DB_PORT
        - name: DB_NAME
          valueFrom:
            configMapKeyRef:
              name: database-config
              key: DB_NAME
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: password
        ports:
        - containerPort: 8080
```

## Example 3: Redis Cache Integration

```yaml
# redis-connection.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config
  namespace: applications
data:
  REDIS_HOST: "redis-app-cache-prod.redis.cache.windows.net"
  REDIS_PORT: "6380"
  REDIS_DB: "0"

---
# app-with-redis.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-redis
  namespace: applications
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app-with-redis
  template:
    metadata:
      labels:
        app: app-with-redis
    spec:
      containers:
      - name: app
        image: myapp:v1
        env:
        - name: REDIS_HOST
          valueFrom:
            configMapKeyRef:
              name: redis-config
              key: REDIS_HOST
        - name: REDIS_PORT
          valueFrom:
            configMapKeyRef:
              name: redis-config
              key: REDIS_PORT
        - name: REDIS_PASSWORD
          valueFrom:
            secretKeyRef:
              name: redis-secret
              key: password
        - name: REDIS_TLS
          value: "true"
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 250m
            memory: 256Mi
          limits:
            cpu: 1000m
            memory: 1Gi
```

## Example 4: Storage Account Integration

```yaml
# storage-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: storage-credentials
  namespace: applications
type: Opaque
stringData:
  storage_account_name: "stappalogsXXX"
  storage_account_key: "YOUR_STORAGE_KEY"

---
# app-with-storage.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-storage
  namespace: applications
spec:
  containers:
  - name: app
    image: myapp:v1
    volumeMounts:
    - name: logs
      mountPath: /var/log/app
    env:
    - name: STORAGE_ACCOUNT
      valueFrom:
        secretKeyRef:
          name: storage-credentials
          key: storage_account_name
    - name: STORAGE_KEY
      valueFrom:
        secretKeyRef:
          name: storage-credentials
          key: storage_account_key
  volumes:
  - name: logs
    emptyDir: {}
```

## Example 5: Horizontal Pod Autoscaler (HPA)

```yaml
# hpa-example.yaml
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
  maxReplicas: 10
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
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
```

## Example 6: Persistent Volume with Azure Disk

```yaml
# pvc-azure-disk.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data-pvc
  namespace: applications
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: managed-csi
  resources:
    requests:
      storage: 10Gi

---
# stateful-app.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: stateful-app
  namespace: applications
spec:
  serviceName: stateful-app
  replicas: 1
  selector:
    matchLabels:
      app: stateful-app
  template:
    metadata:
      labels:
        app: stateful-app
    spec:
      containers:
      - name: app
        image: myapp:v1
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: managed-csi
      resources:
        requests:
          storage: 10Gi
```

## Example 7: Network Policy (Restrict Traffic)

```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-network-policy
  namespace: applications
spec:
  podSelector:
    matchLabels:
      app: web-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: applications
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 3306  # MySQL
    - protocol: TCP
      port: 6380  # Redis
    - protocol: TCP
      port: 443   # HTTPS (DNS, APIs)
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53    # DNS
```

## Example 8: Ingress Configuration

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: applications
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: app-tls-cert
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-service
            port:
              number: 80
```

## Example 9: Resource Quotas and Limits

```yaml
# namespace-quotas.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: applications
labels:
  name: applications

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: application-quota
  namespace: applications
spec:
  hard:
    requests.cpu: "10"
    requests.memory: "20Gi"
    limits.cpu: "20"
    limits.memory: "40Gi"
    pods: "100"
    services: "10"
    services.loadbalancers: "2"

---
apiVersion: v1
kind: LimitRange
metadata:
  name: application-limits
  namespace: applications
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    type: Container
```

## Example 10: Logging and Monitoring

```yaml
# logging-daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-streamer
  namespace: system-services
spec:
  selector:
    matchLabels:
      app: log-streamer
  template:
    metadata:
      labels:
        app: log-streamer
    spec:
      containers:
      - name: log-stream
        image: fluent/fluent-bit:latest
        volumeMounts:
        - name: logs
          mountPath: /var/log
        - name: config
          mountPath: /fluent-bit/etc
        env:
        - name: FLUENT_STORAGE_ACCOUNT
          valueFrom:
            secretKeyRef:
              name: storage-credentials
              key: storage_account_name
      volumes:
      - name: logs
        hostPath:
          path: /var/log
      - name: config
        configMap:
          name: fluent-bit-config
```

## Deployment Instructions

```bash
# 1. Create namespace
kubectl create namespace applications

# 2. Create secrets
cd /path/to/manifests
kubectl apply -f db-secret.yaml
kubectl apply -f redis-secret.yaml
kubectl apply -f storage-secret.yaml

# 3. Create ConfigMaps
kubectl apply -f db-configmap.yaml
kubectl apply -f redis-connection.yaml

# 4. Deploy applications
kubectl apply -f web-app-deployment.yaml
kubectl apply -f app-with-db.yaml
kubectl apply -f app-with-redis.yaml

# 5. Setup HPA
kubectl apply -f hpa-example.yaml

# 6. Verify deployments
kubectl get deployments -n applications
kubectl get pods -n applications
kubectl get services -n applications

# 7. Check logs
kubectl logs -n applications -l app=web-app --tail=50
```

## Troubleshooting Deployments

```bash
# Check pod status
kubectl get pods -n applications

# Describe pod details
kubectl describe pod <pod-name> -n applications

# View pod logs
kubectl logs <pod-name> -n applications

# Check events
kubectl get events -n applications

# Test connectivity
kubectl exec -it <pod-name> -n applications -- bash
```
