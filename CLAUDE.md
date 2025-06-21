# Nezuko Homelab Kubernetes Project

## Project Overview

**Nezuko** is a homelab Kubernetes cluster focused on learning through practical migration of Docker Compose applications to cloud-native patterns. Core mission: Transform Docker Compose-based homelab into production-ready Kubernetes environment with a learning-first approach.

### Key Principles
- **Learning-First**: Explain "why" behind every decision, use k9s for visualization
- **Protective Teaching**: Build correct mental models, prevent bad habits
- **KISS Principle**: Start simple, add complexity only when needed
- **Multi-Node Ready**: Design all applications for pod mobility across cluster nodes

### Success Criteria
- All Docker Compose applications migrated to Kubernetes
- Multi-node pod scheduling with networked storage
- External access through Ingress controllers
- Configuration follows Kubernetes best practices

## Architecture Requirements

### Multi-Node Constraints
- **Pod Mobility**: All applications must support scheduling on any node
- **Storage**: Networked/distributed storage only (never node-local)
- **Networking**: Services accessible from any node
- **Domain**: `dailey.app` for all external access

### Storage Patterns
- **Requirement**: PersistentVolumeClaims for all stateful applications
- **Storage Class**: `rook-ceph-block` for persistent volumes
- **Prohibition**: Never use node-local storage for persistent data
- **Rationale**: Data must survive pod rescheduling across nodes

### Networking Patterns
- **Internal**: Services provide stable DNS endpoints
- **External**: nginx-ingress controller with priority-based routing
- **SWAG Integration**: Hybrid architecture during migration
  - `*.dailey.app` → SWAG backend (catch-all for non-migrated services)
  - Specific domains → Native Kubernetes services
- **Pattern**: Use `service.dailey.app` subdomain structure

## Docker to Kubernetes Translation

### Core Mappings
| Docker Compose | Kubernetes | Purpose |
|----------------|------------|---------|
| `docker-compose.yml` | Multiple YAML manifests | Separation of concerns |
| `./config` bind mounts | PersistentVolumeClaims | Persistent storage |
| `.env` files | ConfigMaps + Secrets | Configuration management |
| `networks` | Services + Ingress | Network connectivity |
| `depends_on` | Init containers/probes | Dependency management |
| Health checks | Liveness/Readiness probes | Health monitoring |

### Migration Workflow
1. **Analyze** existing Docker Compose configuration
2. **Map** services to Kubernetes resources (Deployment, Service, PVC, etc.)
3. **Extract** configuration into ConfigMaps and Secrets
4. **Implement** with proper multi-node support
5. **Validate** using k9s and functional testing

## File Organization Standards

```
_kubernetes/app-name/
├── deployment.yaml      # Main application workload
├── service.yaml         # Network access to pods
├── ingress.yaml         # External HTTP/HTTPS access
├── configmap.yaml       # Non-sensitive configuration
├── secret.yaml          # Sensitive data (passwords, keys)
├── pvc.yaml             # Persistent storage claims
└── kustomization.yaml   # Groups resources together
```

## Tool Usage Hierarchy

1. **k9s**: Primary tool for cluster exploration and learning
   - Use for resource inspection, logs, troubleshooting
   - Preferred over kubectl for visualization and learning
2. **Helmfile**: Declarative Helm release management
   - Use for complex applications requiring Helm charts
   - Preferred over Helm CLI commands
3. **Kustomize**: Resource grouping with `kubectl apply -k`
   - Use for deploying related resources together
4. **kubectl**: Direct commands only when other tools insufficient

## Essential k9s Commands

### Navigation
- `:resource` - View specific resources (`:pods`, `:deploy`, `:svc`, `:pvc`)
- `:workload` - View all workload resources in one view
- `:events` - View cluster events (great for troubleshooting)
- `/filter` - Filter resources by name or label

### Resource Actions
- `d` - Describe selected resource (detailed information)
- `y` - View YAML manifest of selected resource
- `l` - View logs (for pods and containers)
- `s` - Shell into pod or scale deployment
- `f` - Port-forward to selected service/pod

### Troubleshooting Workflow
1. Check `:events` for recent issues
2. Use `:pods` to identify problematic pods
3. View logs with `l` on failing pods
4. Describe resources with `d` to understand configuration

## Configuration Standards

### YAML Formatting
- Minimal quoting: Only quote values when functionally necessary
- Consistent indentation and structure
- Pin chart versions for reproducibility

### Configuration Management
- **ConfigMaps**: Non-sensitive configuration (environment variables, config files)
- **Secrets**: Sensitive data (passwords, API keys, TLS certificates)
- **Security**: Never commit secrets to version control

### Resource Patterns
- **Deployments**: Stateless applications (web servers, APIs)
- **StatefulSets**: Only when ordered deployment truly needed (databases)
- **Services**: Stable network endpoints for pod communication
- **Ingress**: External HTTP/HTTPS access with TLS

## Development Workflow

### Deployment Process
1. Create/modify manifests in `_kubernetes/app-name/`
2. Use `kubectl apply -k` for grouped resource deployment
3. Validate with k9s (resource creation, health, logs)
4. Test application functionality through Ingress
5. Update documentation with lessons learned

### Approval Workflow
- **Mandatory**: All file modifications require explicit "yes" approval
- Ask "Do you want me to implement this?" before any changes
- Never create, edit, or modify files without explicit approval
- This protects the learning environment from unintended changes

### Health Patterns
- **Readiness Probes**: When pod is ready to receive traffic
- **Liveness Probes**: When pod should be restarted
- **Startup Probes**: For slow-starting containers

## Learning Methodology

### Protective Teaching
- Challenge potentially harmful requests before implementation
- Explain best practices alongside quick solutions
- Build correct mental models from the start
- Connect Docker concepts to Kubernetes equivalents

### Configuration Verification
- Always verify actual configuration requirements vs assumptions
- Check existing ConfigMaps and resources before configuring
- Test incrementally and validate before proceeding
- Question assumptions when something "should work" but doesn't

### Common Pitfalls to Avoid
- Assuming resource names match underlying identifiers
- Using documentation examples without verifying local configuration
- Implementing complex solutions when simple ones suffice
- Bypassing safety mechanisms for convenience

## Frequently Used Commands

### Cluster Management
```bash
# Apply grouped resources
kubectl apply -k _kubernetes/app-name/

# Check cluster status with k9s
k9s

# View specific resource types
kubectl get pods -A
kubectl get pvc -A
kubectl get ingress -A
```

### Troubleshooting
```bash
# View events
kubectl get events --sort-by='.metadata.creationTimestamp'

# Check logs
kubectl logs -f deployment/app-name

# Port forward for testing
kubectl port-forward svc/app-service 8080:80
```

### Storage Operations
```bash
# List storage classes
kubectl get storageclass

# Check PVC status
kubectl get pvc -A

# Describe storage issues
kubectl describe pvc pvc-name
```

## Memory Bank System

A system for maintaining context across Claude Code sessions for long-running
initiatives. Each initiative is tracked in a dedicated file that preserves progress,
decisions, and current state.

@memory-bank/_system-docs.md

Remember: This is a learning environment. Always explain the "why" behind decisions and prioritize understanding over quick fixes.