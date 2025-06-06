# Homer Kustomize Configuration

This directory contains the Kustomize configuration for deploying Homer dashboard to Kubernetes.

## Migration from Docker Compose

This setup migrates the following Docker Compose features to Kubernetes:

- **Image**: `b4bz/homer:v25.05.2`
- **Environment Variables**: TZ=America/Chicago (via ConfigMap)
- **Volumes**: `./assets:/www/assets` (via PersistentVolumeClaim)
- **User**: Configured as securityContext with UID/GID 1000
- **Networking**: Service and Ingress for external access
- **Restart Policy**: `unless-stopped` → `Always`

## Files Structure

- `kustomization.yaml` - Main Kustomize configuration
- `namespace.yaml` - Homer namespace
- `deployment.yaml` - Main application deployment
- `service.yaml` - ClusterIP service for internal access
- `configmap.yaml` - Environment variables
- `pvc.yaml` - Persistent storage for assets
- `ingress.yaml` - External access configuration

## Deployment

1. **Review and customize the configuration**:
   - Update the ingress host in `ingress.yaml` to match your domain
   - Adjust resource limits in `deployment.yaml` if needed
   - Modify timezone in `configmap.yaml` if required

2. **Deploy using kubectl**:
   ```bash
   kubectl apply -k .
   ```

3. **Verify deployment**:
   ```bash
   kubectl get all -n homer
   ```

## Configuration Notes

- **Storage**: The PVC is set to 1Gi which should be sufficient for Homer assets
- **Security**: Runs as non-root user (1000:1000)
- **Ingress**: Configured for nginx-ingress with Let's Encrypt TLS
- **Resources**: Conservative memory (64Mi-128Mi) and CPU (250m-500m) limits

## Customization

To customize the deployment for different environments, you can:

1. Create overlay directories (e.g., `overlays/staging`, `overlays/production`)
2. Use Kustomize patches to modify specific resources
3. Use environment-specific ingress configurations

## Accessing Homer

Once deployed, Homer will be accessible via:
- Internal cluster: `http://homer.homer.svc.cluster.local:8080`
- External (if ingress configured): `https://home.yourdomain.com`
