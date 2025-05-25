# k9s Essential Commands Reference

## Navigation & Resources

### Basic Navigation
- `:resource` - View specific resources (`:pods`, `:deploy`, `:svc`, `:pvc`, `:nodes`)
- `:workload` - View all workload resources (deployments, pods, services, replicasets) in one view
- `:ns` - Switch namespaces
- `:ctx` - Switch contexts
- `Ctrl+A` - Show all available aliases
- `/filter` - Filter resources by name or label
- `Esc` - Clear filter or go back to previous view

### Resource Selection
- `j/k` or `↑/↓` - Navigate up/down through resource list
- `SPACE` - Multi-select resources
- `Ctrl+\` - Clear current selection
- `Enter` - Drill down into selected resource

## Resource Actions

### Information and Inspection
- `d` - Describe selected resource (detailed information)
- `y` - View YAML manifest of selected resource
- `e` - Edit resource (opens in editor)
- `l` - View logs (for pods and containers)

### Resource Management
- `s` - Shell into pod or scale deployment
- `Ctrl+D` - Delete resource (with confirmation)
- `Ctrl+K` - Kill resource (force delete)
- `f` - Port-forward to selected service/pod

## Useful Views

### Cluster Overview
- `:events` - View cluster events (great for troubleshooting)
- `:pulse` - Cluster resource usage overview
- `:xray deploy` - Resource hierarchy view (shows relationships)

### Workload Management
- `:deploy` - Deployments
- `:pods` - All pods
- `:svc` - Services
- `:ing` - Ingress resources
- `:pvc` - Persistent Volume Claims
- `:cm` - ConfigMaps
- `:sec` - Secrets

### Monitoring and Troubleshooting
- `:top node` - Node resource usage
- `:top pod` - Pod resource usage
- `:events` - Recent cluster events
- `:logs` - Pod logs with filtering

## Learning-Focused Usage Patterns

### Understanding Resource Relationships
1. Start with `:workload` to see all related resources
2. Use `:xray deploy` to visualize relationships
3. Drill down with `Enter` to explore connections
4. Use `d` to understand resource configurations

### Troubleshooting Workflow
1. Check `:events` for recent issues
2. Use `:pods` to identify problematic pods
3. View logs with `l` on failing pods
4. Describe resources with `d` to understand configuration
5. Check resource usage with `:top pod` and `:top node`

### Configuration Learning
1. Use `y` to view YAML manifests
2. Compare working vs. non-working resources
3. Use `d` to understand resource relationships
4. Edit with `e` to experiment safely

## Pro Tips for Learning

### Efficient Navigation
- Learn the resource aliases (`:po` for pods, `:svc` for services, etc.)
- Use filters (`/`) to quickly find specific resources
- Bookmark frequently used views with custom aliases

### Understanding Kubernetes
- Always check `:events` when something isn't working
- Use `:xray` views to understand how resources connect
- Compare YAML (`y`) between similar resources to learn patterns
- Use describe (`d`) to understand status and conditions

### Safe Experimentation
- Use multi-select (`SPACE`) for bulk operations
- Always describe (`d`) before deleting resources
- Use port-forward (`f`) to test connectivity
- Check logs (`l`) to understand application behavior

This reference should be used alongside hands-on practice to build muscle memory and understanding of Kubernetes cluster management through k9s.
