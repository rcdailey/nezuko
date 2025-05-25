# Product Context: Why Nezuko Exists

## The Problem

**Current State**: Homelab running on Docker Compose with multiple services
- Applications tied to specific host machines
- Manual configuration management
- Limited scalability and resilience
- Learning plateau with container orchestration

**Pain Points**:
- Services fail when host goes down
- Configuration scattered across multiple `.env` files
- No standardized deployment patterns
- Difficult to implement proper networking and security
- Limited learning opportunities for cloud-native technologies

## The Solution

**Vision**: Transform homelab into a learning-focused Kubernetes environment that demonstrates production-ready patterns while maintaining simplicity.

**Core Value Proposition**:
- **Learn by Doing**: Practical Kubernetes education through real application migration
- **Production Patterns**: Implement best practices from day one
- **Resilient Infrastructure**: Multi-node cluster with proper failover
- **Standardized Deployment**: Consistent patterns across all applications

## User Experience Goals

### For the Learner (Primary User)
- **Safe Learning Environment**: Mistakes don't cause data loss or system instability
- **Clear Mental Models**: Understand why Kubernetes works the way it does
- **Practical Knowledge**: Learn through real-world application migration
- **Best Practices**: Build correct habits from the beginning
- **Progressive Complexity**: Start simple, add sophistication as understanding grows

### For the Operator (Secondary User)
- **Reliable Services**: Applications survive node failures
- **Easy Management**: Standardized deployment and configuration patterns
- **Monitoring**: Clear visibility into application health and performance
- **Maintenance**: Simple upgrade and rollback procedures

## Success Metrics

### Learning Objectives
- Understand core Kubernetes concepts through practical application
- Successfully migrate all Docker Compose applications
- Implement proper storage, networking, and security patterns
- Develop troubleshooting skills with k9s and kubectl

### Operational Objectives
- Zero-downtime deployments for all applications
- Automatic failover when nodes go down
- Centralized configuration management
- Proper external access through Ingress controllers

## Key Differentiators

### Learning-First Approach
Unlike typical homelab setups that focus purely on functionality, Nezuko prioritizes education:
- Every decision is explained with the "why"
- Protective methodology prevents harmful practices
- Real-world analogies make complex concepts accessible
- k9s prioritized for better visualization and learning

### Production-Ready from Start
Rather than quick hacks that work in development but fail in production:
- Multi-node architecture from day one
- Proper storage patterns (networked, not local)
- Security best practices built in
- Scalable networking patterns

### KISS Philosophy
Complexity is added only when needed:
- Start with minimal configurations
- Leverage software defaults
- Add features based on actual requirements, not theoretical needs
- Maintain simplicity for better learning and maintenance
