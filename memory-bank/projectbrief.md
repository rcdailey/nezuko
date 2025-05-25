# Nezuko Homelab Kubernetes Project Brief

## Project Overview

**Nezuko** is a personal homelab Kubernetes cluster focused on learning Kubernetes through practical migration of Docker Compose applications to cloud-native patterns.

## Core Mission

Transform a Docker Compose-based homelab into a production-ready Kubernetes environment while maintaining a **learning-first approach** that builds correct mental models and sustainable practices.

## Primary Goals

1. **Learning Environment**: Create a safe space to learn Kubernetes concepts through hands-on migration
2. **Docker Migration**: Convert existing Docker Compose applications to Kubernetes manifests
3. **Best Practices**: Implement production-ready patterns from the start
4. **Multi-Node Ready**: Design all applications for pod mobility across cluster nodes

## Key Principles

### Learning-First Methodology
- Explain the "why" behind every decision and concept
- Connect Docker concepts to Kubernetes equivalents
- Use real-world analogies for complex concepts
- Prioritize k9s for visualization and learning
- Challenge potentially harmful requests with education

### Protective Teaching
- Build correct mental models from the start
- Prevent formation of bad habits
- Offer safe alternatives to risky approaches
- Always explain best practices alongside quick solutions

### KISS Principle
- Start with minimal configurations
- Add complexity only when needed
- Leverage excellent software defaults
- Prioritize learning and functionality over enterprise complexity

## Success Criteria

- All Docker Compose applications successfully migrated to Kubernetes
- Cluster supports multi-node pod scheduling
- Applications use networked storage for persistence
- External access properly configured through Ingress
- Configuration follows Kubernetes best practices
- Learning objectives met through practical implementation

## Constraints

- **Domain**: `dailey.app` for external access
- **Storage**: Must use networked/distributed storage (no node-local)
- **Architecture**: Multi-node cluster requiring pod mobility
- **Approval**: All file modifications require explicit approval
- **Documentation**: Maintain comprehensive learning documentation
