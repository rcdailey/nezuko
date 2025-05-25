# Active Context: Current Focus and Decisions

## Current Work Focus

### Primary Objective

Continuing Docker Compose to Kubernetes migration with SWAG integration as bridge architecture.

### Recent Activity

- Completed comprehensive cluster assessment (June 19, 2025)
- Confirmed Homer dashboard successfully migrated and running at `home.dailey.app`
- Validated SWAG fallback ingress working as catch-all for non-migrated services
- Assessed Rook Ceph storage cluster - fully operational with 3 OSDs
- Identified next migration candidates: cloudflared, uptime_kuma, authentik

## Active Decisions and Considerations

### Learning Methodology Implementation

- **Protective Teaching**: Challenge potentially harmful requests before implementation
- **Explanation Priority**: Always explain the "why" behind decisions
- **k9s First**: Prioritize k9s over kubectl for learning and visualization
- **KISS Principle**: Start simple, add complexity only when needed

### Configuration Verification Approach

**Critical Pattern**: Always verify actual configuration requirements rather than making assumptions

- Check existing ConfigMaps and resources before configuring integrations
- Understand abstraction layers and what identifiers each layer expects
- Test incrementally and validate before proceeding
- Question assumptions when something "should work" but doesn't

### Approval Workflow

**Mandatory**: All file modifications require explicit "yes" approval

- Stop and ask "Do you want me to implement this?" before any changes
- Never create, edit, or modify files without explicit approval
- This protects the learning environment from unintended changes

## Important Patterns and Preferences

### Docker to Kubernetes Migration Strategy

1. **Analyze** existing Docker Compose configuration
2. **Map** services to Kubernetes resources (Deployment, Service, PVC, etc.)
3. **Extract** configuration into ConfigMaps and Secrets
4. **Implement** with proper multi-node support
5. **Validate** using k9s and functional testing

### File Organization Standards

```
_kubernetes/app-name/
├── deployment.yaml
├── service.yaml
├── ingress.yaml
├── configmap.yaml
├── secret.yaml
├── pvc.yaml
└── kustomization.yaml
```

### Tool Usage Hierarchy

1. **k9s**: Primary tool for cluster exploration and learning
2. **Helmfile**: Declarative Helm release management
3. **Kustomize**: Resource grouping with `kubectl apply -k`
4. **kubectl**: Direct commands only when other tools insufficient

## Current Technical Context

### Environment Specifics

- **Domain**: `dailey.app` for all external access
- **Architecture**: 3-node K3s cluster (lucy, marin, nami) - all Ready
- **Storage**: Rook Ceph distributed storage (3 OSDs, fully operational)
- **Ingress**: nginx-ingress with SWAG backend integration
- **Migration Source**: Docker Compose applications in project directories

### Current Cluster Status

**Migrated to Kubernetes:**
- **Homer Dashboard**: Running at `home.dailey.app` with rook-ceph-block storage

**SWAG Integration Architecture:**
- **Primary Route**: `*.dailey.app` → SWAG backend (192.168.1.58:30443) [priority 1, catch-all]
- **Native K8s Routes**: Specific domains route directly to Kubernetes services
- **Bridge Strategy**: Gradual migration while maintaining service availability

**Available for Migration:**
- cloudflared (tunnel) - Simple networking service
- uptime_kuma (monitoring) - Good for health check patterns
- authentik (authentication) - Complex but high-value service
- immich (photo management) - Storage-intensive application
- librechat (AI chat) - API integration patterns
- media stack - Complex multi-service application

## Learning Insights and Project Evolution

### Key Realizations

- **Configuration Debugging**: Start with understanding what the system actually expects, not assumptions
- **Abstraction Layers**: Each layer (Kubernetes, Helm, operators) may expect different identifiers
- **Incremental Validation**: Apply changes and test before proceeding to next step

### Methodology Refinements

- **Research Online**: Always check official documentation for current, accurate information
- **Protective Approach**: Challenge requests that could lead to bad practices or system instability
- **Teaching Focus**: Build correct mental models from the start rather than quick fixes

### Common Pitfalls to Avoid

- Assuming resource names match underlying identifiers
- Using documentation examples without verifying local configuration
- Implementing complex solutions when simple ones suffice
- Bypassing safety mechanisms for convenience

## Next Steps and Priorities

### Immediate Tasks

1. Complete memory bank creation with remaining files (progress.md)
2. Validate memory bank structure and content organization
3. Test memory bank effectiveness for knowledge retrieval

### Migration Priorities

- Start with simpler applications (static sites, single-container apps)
- Progress to more complex applications (databases, multi-service apps)
- Document patterns and lessons learned for future migrations

### Learning Objectives

- Master k9s for cluster management and troubleshooting
- Understand Kubernetes networking and storage patterns
- Develop expertise in Helmfile for complex deployments
- Build troubleshooting skills for common Kubernetes issues

## Decision Log

### Architecture Decisions

- **Multi-node first**: Design all applications for pod mobility from day one
- **Networked storage**: Never use node-local storage for persistent data
- **Ingress pattern**: Use consistent `service.dailey.app` domain structure

### Tool Decisions

- **k9s over kubectl**: Better learning experience and visualization
- **Helmfile over Helm CLI**: Declarative, version-controlled configuration
- **Kustomize integration**: Group related resources for easier management

### Process Decisions

- **Approval required**: All file modifications need explicit permission
- **Incremental approach**: Migrate one application at a time
- **Documentation first**: Update memory bank with lessons learned
