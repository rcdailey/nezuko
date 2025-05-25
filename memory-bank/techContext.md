# Technical Context: Nezuko Technology Stack

## Core Technologies

### Kubernetes Ecosystem
- **Kubernetes**: Container orchestration platform
- **kubectl**: Command-line tool for cluster management
- **k9s**: Terminal-based UI for Kubernetes cluster management (preferred tool)
- **Kustomize**: Native Kubernetes configuration management

### Package Management
- **Helm**: Kubernetes package manager for complex applications
- **Helmfile**: Declarative configuration for Helm releases (preferred over complex Helm commands)

### Storage
- **Rook Ceph**: Distributed block and filesystem storage for Kubernetes
- **Storage Classes**: `rook-ceph-block` for persistent volumes
- **Cluster Status**: 3 OSDs (one per node), 3 monitors, 2 managers - fully operational
- **Requirement**: All storage must be networked/distributed (no node-local storage)

### Networking
- **Ingress Controllers**: Handle external HTTP/HTTPS traffic
- **Services**: Provide stable network endpoints for pods
- **DNS**: Kubernetes native service discovery

## Development Environment

### Domain Configuration
- **Primary Domain**: `dailey.app`
- **Pattern**: `service.dailey.app` for application access
- **SSL/TLS**: Managed through Ingress controllers

### File Structure
- **Source**: `/mnt/fast/docker/` (Docker Compose applications)
- **Target**: `_kubernetes/` (Kubernetes manifests)
- **Organization**: One directory per application with standardized file layout

### Tool Preferences
- **k9s over kubectl**: Prioritize k9s for learning and visualization
- **Helmfile over Helm CLI**: Use declarative configuration files
- **Kustomize**: Use `kubectl apply -k` for grouped resource deployment

## Configuration Management

### YAML Standards
- **Minimal Quoting**: Only quote values when functionally necessary
- **Context Awareness**: Consider the consuming tool's parsing requirements
- **Consistency**: Maintain consistent formatting across manifests

### Secret Management
- **Separation**: Distinguish sensitive (Secrets) from non-sensitive (ConfigMaps) data
- **Security**: Never commit secrets to version control
- **Injection**: Use external secret management when possible

### Version Control
- **Git**: All configuration stored in version control
- **Pinning**: Always pin chart versions for reproducibility
- **Documentation**: Maintain clear commit messages and documentation

## Operational Patterns

### Deployment Workflow
1. **Development**: Create/modify manifests in `_kubernetes/app-name/`
2. **Validation**: Use k9s to verify resource creation and health
3. **Testing**: Validate application functionality through Ingress
4. **Documentation**: Update memory bank with lessons learned

### Troubleshooting Tools
- **k9s**: Primary interface for cluster exploration and debugging
- **kubectl**: Command-line operations when k9s isn't sufficient
- **Logs**: Application and system log analysis
- **Events**: Kubernetes event monitoring for issues

### Monitoring Approach
- **Health Probes**: Implement readiness, liveness, and startup probes
- **Resource Monitoring**: Track CPU, memory, and storage usage
- **Application Metrics**: Monitor application-specific metrics
- **Alerting**: Set up notifications for critical issues

## Learning Resources Integration

### Online Documentation
- **Kubernetes Docs**: Official Kubernetes documentation
- **Helm Hub**: Chart repository and documentation
- **Tool-Specific Docs**: Always reference official documentation for accuracy

### Hands-On Learning
- **k9s Exploration**: Use k9s to understand cluster state and relationships
- **Incremental Migration**: Move one Docker Compose service at a time
- **Experimentation**: Safe environment for trying new patterns and approaches

## Technical Constraints

### Multi-Node Requirements
- **Pod Mobility**: All applications must support scheduling on any node
- **Storage**: No node-local storage dependencies
- **Networking**: Services must be accessible from any node
- **Scheduling**: Consider node affinity and anti-affinity rules

### Resource Limitations
- **Hardware**: Work within homelab hardware constraints
- **Network**: Consider bandwidth limitations for image pulls and data transfer
- **Storage**: Balance performance with cost for storage solutions

### Security Considerations
- **Network Policies**: Implement appropriate network segmentation
- **RBAC**: Use role-based access control for cluster security
- **Image Security**: Use trusted container images and registries
- **Secret Management**: Proper handling of sensitive configuration data

## Integration Patterns

### External Services
- **DNS**: Integration with external DNS providers
- **SSL/TLS**: Certificate management and renewal
- **Monitoring**: Integration with external monitoring systems
- **Backup**: Data backup and disaster recovery procedures

### Development Workflow
- **Local Development**: Patterns for local application development
- **CI/CD**: Continuous integration and deployment considerations
- **Testing**: Application and infrastructure testing approaches
- **Rollback**: Safe rollback procedures for failed deployments
