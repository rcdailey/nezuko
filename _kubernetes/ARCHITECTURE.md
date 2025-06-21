# Nezuko Kubernetes Architecture

## Overview

Nezuko implements a sophisticated **hybrid ingress architecture** that enables gradual
migration from Docker Compose to Kubernetes while maintaining zero downtime for existing
services. The system uses priority-based routing through nginx-ingress to seamlessly
blend cloud-native and traditional deployment patterns.

## Complete Request Flow

```
Client Browser
    ↓
home.dailey.app
    ↓
Cloudflare SSL Certificate (public SSL termination)
    ↓
Cloudflare Proxy
    ↓
Homelab Public IP
    ↓
nginx-ingress Controller
    ↓
Priority-Based Routing Decision:
    ├─ High Priority: Specific hosts (home.dailey.app)
    │   ↓
    │   Kubernetes Services → homer service (port 8080) → Homer Pod
    │
    └─ Low Priority: Wildcard (*.dailey.app)
        ↓
        swag-backend service → SWAG Container (192.168.1.58:30443)
        ↓
        Docker Compose Services (non-migrated apps)
```

## SSL Architecture Layers

### Layer 1: Internet SSL (Cloudflare ↔ Client)

```
Client Browser ←→ Cloudflare Edge
```

- **Certificate**: Cloudflare's public SSL certificate
- **Management**: Cloudflare dashboard
- **Termination**: At Cloudflare edge servers
- **Client Experience**: Valid, trusted SSL connection
- **Configuration**: Cloudflare SSL/TLS settings

### Layer 2: Origin SSL (nginx-ingress ↔ SWAG)

```
nginx-ingress ←→ SWAG Container (192.168.1.58:30443)
```

- **Certificate**: SWAG's internal SSL certificate
- **Management**: SWAG `/config/keys/` directory + `ssl.conf`
- **Protocol**: HTTPS (enforced by backend-protocol annotation)
- **Verification**: Disabled (proxy-ssl-verify: off)
- **Purpose**: Secure communication between nginx-ingress and legacy services

### Layer 3: Internal Communication (nginx-ingress ↔ Kubernetes)

```
nginx-ingress ←→ Kubernetes Services
```

- **Certificate**: None (HTTP only)
- **Security**: Kubernetes network policies + cluster isolation
- **Protocol**: HTTP (internal cluster communication)
- **Management**: Service mesh patterns (future consideration)

## Priority-Based Routing Configuration

### High Priority: Specific Host Routes

Specific host ingress resources (like `host: home.dailey.app`) automatically receive higher
priority than wildcard patterns. nginx-ingress evaluates exact matches first, then falls
back to wildcard patterns.

**Configuration**: Standard ingress with specific hostname
**Behavior**: Direct routing to Kubernetes services, bypassing SWAG entirely
**Example**: `home.dailey.app` → homer service (port 8080)

### Low Priority: Wildcard Catch-All

The wildcard ingress uses explicit priority annotation `priority: "1"` (lower numbers =
lower priority) and special backend protocol configuration to route to SWAG over HTTPS.

**Configuration**: Wildcard host `*.dailey.app` with backend-protocol HTTPS
**Behavior**: Routes to swag-backend service, which connects to SWAG container
**Purpose**: Maintains access to all non-migrated Docker Compose services

## Service Backend Configuration

### swag-backend Service

The swag-backend service is a Kubernetes service that points to an external IP address
(192.168.1.58) where the SWAG container runs. This creates a bridge between the Kubernetes
cluster and the existing Docker Compose infrastructure.

**Service Configuration**:
- **Type**: ClusterIP (internal to cluster)
- **Port mapping**: 443 → 30443 (SWAG's published HTTPS port)
- **External endpoint**: Direct IP connection to SWAG host

**Key Details**:
- Points to IP outside Kubernetes cluster
- Bypasses Docker networking for direct connection
- Enables nginx-ingress to route traffic to legacy services

## Migration Workflow

### Current State Example

```
home.dailey.app     → nginx-ingress → homer (Kubernetes)
plex.dailey.app     → nginx-ingress → swag-backend → SWAG → Plex (Docker)
sonarr.dailey.app   → nginx-ingress → swag-backend → SWAG → Sonarr (Docker)
```

### After Next Migration

```
home.dailey.app     → nginx-ingress → homer (Kubernetes)
uptime.dailey.app   → nginx-ingress → uptime-kuma (Kubernetes)  ← NEW
plex.dailey.app     → nginx-ingress → swag-backend → SWAG → Plex (Docker)
sonarr.dailey.app   → nginx-ingress → swag-backend → SWAG → Sonarr (Docker)
```

### Migration Process

1. **Deploy to Kubernetes**: Create deployment, service, ingress with specific host
2. **Test accessibility**: Verify new route works correctly
3. **Automatic priority**: nginx-ingress automatically prioritizes specific host over wildcard
4. **Zero downtime**: No changes needed to existing services

## Architecture Benefits

### 1. **Zero Downtime Migration**
- Existing services continue working through SWAG
- New services added incrementally
- No "big bang" migration required

### 2. **Seamless User Experience**
- All services remain accessible at same URLs
- SSL certificates unchanged (Cloudflare managed)
- No DNS changes required during migration

### 3. **Flexible Rollback**
- Can easily revert specific services to SWAG
- Independent service migration timeline
- Low risk deployment pattern

### 4. **Progressive Complexity**
- Start with simple single-service applications
- Build expertise before tackling complex stacks
- Learn Kubernetes patterns incrementally

### 5. **Optimal Resource Usage**
- Kubernetes services only consume resources when migrated
- SWAG continues handling non-migrated load
- Gradual resource transition

## Current Service Routing

### Migrated to Kubernetes
- **home.dailey.app** → homer service (port 8080)

### Still on SWAG (48 services)
- **All other *.dailey.app** → swag-backend → SWAG → Docker Compose services

## SSL Configuration Files

### Active SSL Configurations

1. **Cloudflare Dashboard**: Internet-facing SSL termination
2. **SWAG `/mnt/fast/docker/swag/config/nginx/ssl.conf`**: nginx-ingress ↔ SWAG encryption
3. **Kubernetes**: No SSL configuration needed (receives decrypted traffic)

### SWAG SSL Configuration (Currently Active)

SWAG uses Mozilla Intermediate Security configuration with TLS 1.2/1.3 support, modern
cipher suites, and proper session management. The configuration is located at
`/mnt/fast/docker/swag/config/nginx/ssl.conf`.

**Purpose**: Secures communication between nginx-ingress and SWAG for non-migrated services
**Protocols**: TLS 1.2 and 1.3
**Certificate location**: `/config/keys/cert.crt` and `/config/keys/cert.key`

## Future Considerations

### Full Kubernetes SSL Migration

When ready to move SSL entirely to Kubernetes:

1. **Install cert-manager**: Automated Let's Encrypt certificate management
2. **Add TLS sections** to Ingress resources with certificate secrets
3. **Update Cloudflare**: Point DNS directly to nginx-ingress
4. **Decommission SWAG**: Complete migration to cloud-native SSL

### Service Mesh Integration

For advanced networking:
- **Istio/Linkerd**: Service-to-service encryption
- **mTLS**: Mutual TLS between services
- **Traffic policies**: Advanced routing and security rules

## Troubleshooting

### Common Issues

1. **Service not accessible**: Check ingress priority and host specificity
2. **SSL errors to SWAG**: Verify swag-backend endpoints and SWAG certificate
3. **Wrong service routing**: Ensure specific hosts override wildcard patterns
4. **Cloudflare issues**: Check SSL mode and origin certificate configuration

### Debugging Commands

```bash
# Check ingress routing
kubectl get ingress -A

# Verify service endpoints
kubectl get endpoints swag-backend -n ingress-nginx -o yaml

# Check nginx-ingress logs
kubectl logs -n ingress-nginx deployment/nginx-ingress-ingress-nginx-controller

# Test internal connectivity
kubectl port-forward svc/swag-backend -n ingress-nginx 8443:443
```

This architecture represents a sophisticated approach to cloud-native migration that
prioritizes learning, stability, and gradual transformation over disruptive change.