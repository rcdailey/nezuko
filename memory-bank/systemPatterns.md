# System Patterns: Nezuko Architecture

## Core Architecture

### Multi-Node Kubernetes Cluster
- **Design Principle**: All applications must support pod mobility across nodes
- **Resilience**: No single points of failure at the node level
- **Scheduling**: Consider anti-affinity rules for critical services

### Storage Architecture
- **Requirement**: Networked/distributed storage only (NFS, Longhorn)
- **Prohibition**: Never use node-local storage for persistent data
- **Pattern**: PersistentVolumeClaims for all stateful applications
- **Rationale**: Data must survive pod rescheduling across nodes

### Networking Patterns
- **Internal Communication**: Services provide stable endpoints
- **External Access**: nginx-ingress controller with priority-based routing
- **SWAG Integration**: Hybrid architecture during migration phase
  - `*.dailey.app` (priority 1) → SWAG backend (catch-all for non-migrated services)
  - Specific domains → Native Kubernetes services (e.g., `home.dailey.app` → Homer)
- **Domain Strategy**: Use `dailey.app` subdomain pattern for all services
- **Service Discovery**: DNS-based service resolution within cluster

## Docker to Kubernetes Translation Patterns

### Core Concept Mappings

| Docker Compose | Kubernetes | Purpose |
|----------------|------------|---------|
| `docker-compose.yml` | Multiple YAML manifests | Separation of concerns |
| `./config` bind mounts | PersistentVolumeClaims | Persistent storage |
| `.env` files | ConfigMaps + Secrets | Configuration management |
| `networks` | Services + Ingress | Network connectivity |
| `depends_on` | Init containers/probes | Dependency management |
| Health checks | Liveness/Readiness probes | Health monitoring |

### Migration Workflow Pattern

1. **Analyze Docker Compose**
   - Identify services and their dependencies
   - Map volumes to storage requirements
   - Extract configuration and secrets
   - Document networking requirements

2. **Design Kubernetes Resources**
   - Deployment for application workload
   - Service for network access
   - PVC for persistent storage
   - ConfigMap for non-sensitive config
   - Secret for sensitive data
   - Ingress for external access

3. **Implement with Kustomization**
   - Group related resources
   - Use `kubectl apply -k` for deployment
   - Maintain resource relationships

## File Organization Pattern

```
_kubernetes/
├── app-name/
│   ├── deployment.yaml      # Main application workload
│   ├── service.yaml         # Network access to pods
│   ├── ingress.yaml         # External HTTP/HTTPS access
│   ├── configmap.yaml       # Non-sensitive configuration
│   ├── secret.yaml          # Sensitive data (passwords, keys)
│   ├── pvc.yaml             # Persistent storage claims
│   └── kustomization.yaml   # Groups resources together
```

## Resource Patterns

### Workload Patterns
- **Deployments**: Stateless applications (web servers, APIs)
  - Manages ReplicaSets and rolling updates
  - Suitable for applications that can be killed and restarted
- **StatefulSets**: Stateful applications requiring ordered deployment
  - Provides stable network identity and ordered scaling
  - Use only when truly needed (databases, message queues)

### Storage Patterns
- **PersistentVolumeClaims**: All persistent data
  - Always specify networked storage class
  - Size appropriately for application needs
  - Use ReadWriteOnce for single-pod access
  - Use ReadWriteMany for multi-pod shared access

### Configuration Patterns
- **ConfigMaps**: Non-sensitive configuration
  - Environment variables
  - Configuration files
  - Application settings
- **Secrets**: Sensitive data
  - Passwords and API keys
  - TLS certificates
  - Database connection strings

### Health Check Patterns
- **Readiness Probes**: When pod is ready to receive traffic
- **Liveness Probes**: When pod should be restarted
- **Startup Probes**: For slow-starting containers

## Helmfile Patterns

### Release Management
- **Pin Chart Versions**: Always specify exact versions for reproducibility
- **Environment Values**: Use `.StateValues` for Helmfile-specific configuration
- **Release Templates**: Abstract common patterns with `inherit` field
- **Directory Structure**: Follow `config/{{ .Release.Name }}/` convention

### Configuration Layering
- **Base Configuration**: Common settings across environments
- **Environment Overrides**: Environment-specific values
- **Secret Management**: External secret injection patterns
- **Value Composition**: Use `get` function for optional values

## Common Migration Patterns

### Reverse Proxy Pattern
**Docker Compose**: SWAG container with labels
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.app.rule=Host(`app.domain.com`)"
```

**Kubernetes**: Ingress resource
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  rules:
  - host: app.dailey.app
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
```

### Database Pattern
**Docker Compose**: Linked containers
```yaml
services:
  app:
    depends_on:
      - postgres
  postgres:
    image: postgres:15
```

**Kubernetes**: Service discovery
```yaml
# App connects to: postgres-service:5432
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
```

### Volume Pattern
**Docker Compose**: Bind mounts
```yaml
volumes:
  - ./config:/app/config
```

**Kubernetes**: PVC mounts
```yaml
volumeMounts:
- name: config-storage
  mountPath: /app/config
volumes:
- name: config-storage
  persistentVolumeClaim:
    claimName: app-config-pvc
