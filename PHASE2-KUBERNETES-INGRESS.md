# Phase 2+: Kubernetes Ingress Migration - Copilot Context

## Context and History

This phase builds on Phase 1's successful Cloudflare tunnel implementation and represents the core
Kubernetes migration strategy. The approach was developed based on Discord community insights from
experienced Kubernetes homelab users who recommended using nginx-ingress with
`--default-backend-service` pointing to the existing SWAG infrastructure. This strategy enables
incremental service migration rather than requiring all services to move at once. The key
breakthrough insight is that nginx-ingress can act as a "smart router" - matching ingress rules go
to Kubernetes services, while unmatched requests automatically fall back to SWAG/Docker services.
This eliminates the need for complex wildcard routing or service disruption. The approach
prioritizes Helmfile over complex Helm commands for declarative, version-controlled infrastructure
management, aligning with DevOps best practices. The migration pattern supports a learning-focused
methodology where simple services (Homer, Uptime Kuma) can be migrated first to build confidence and
expertise before tackling more complex applications.

## Current State

- Traffic: Internet → Cloudflare → Cloudflared → SWAG → Docker services
- Domain: dailey.app routing through Cloudflare tunnel
- Goal: Insert nginx-ingress between Cloudflared and SWAG

## Target Architecture

```text
Internet → Cloudflare → Cloudflared → nginx-ingress (K8s)
                                           │
                                           ├─ home.dailey.app → Homer (K8s)
                                           └─ *.dailey.app → SWAG → Docker Services
```

## Implementation

### Step 1: Deploy nginx-ingress via Helmfile

```yaml
# helmfile.yaml
helmDefaults:
  wait: true
  timeout: 600

repositories:
  - name: ingress-nginx
    url: https://kubernetes.github.io/ingress-nginx

releases:
  - name: nginx-ingress
    namespace: ingress-nginx
    createNamespace: true
    chart: ingress-nginx/ingress-nginx
    version: "~4.8.0"
    values:
      - controller:
          service:
            type: NodePort
            nodePorts:
              https: 30443
          extraArgs:
            default-backend-service: "ingress-nginx/swag-backend"
```

Deploy: `helmfile apply`

### Key Insight: Default Backend Strategy

nginx-ingress `--default-backend-service` automatically routes unmatched requests to SWAG, enabling zero-config fallback for non-migrated services. No wildcard ingress rules needed.

### Step 2: Create SWAG Backend Service

```yaml
# swag-backend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: swag-backend
  namespace: ingress-nginx
spec:
  type: ExternalName
  externalName: 192.168.1.58
  ports:
  - name: https
    port: 443
    protocol: TCP
```

### Step 3: Update Cloudflared

Cloudflare Zero Trust → Tunnels → Edit rule:

- URL: `https://192.168.1.100:30443` (K8s node IP - NodePort enables multi-node support)

### Step 4: Service Migration Priority

**Migrate First**: Homer, Uptime Kuma (simple web services)
**Keep on Docker**: Plex, qBittorrent, SABnzbd (high bandwidth/complex)

**Migration Pattern**:

For each service:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: service-name
spec:
  ingressClassName: nginx
  rules:
  - host: service.dailey.app
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: service-name
            port:
              number: 80
```

## Validation Steps

```bash
# Check deployment
helmfile status
kubectl get pods -n ingress-nginx

# Test traffic routing
curl -v https://home.dailey.app  # Should work through SWAG fallback
```

## Next Action

Create and deploy Helmfile configuration for nginx-ingress with SWAG default backend.
