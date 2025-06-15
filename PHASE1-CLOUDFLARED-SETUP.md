# Phase 1: Cloudflared Setup - Copilot Context

## Context and History

This migration plan emerged from a homelab Docker Compose to Kubernetes transition project. The
current infrastructure uses SWAG (nginx reverse proxy) handling all external traffic through router
port forwarding (443 → nezuko:443), with multiple Docker Compose services behind it. The migration
strategy was designed for zero-downtime, incremental transition rather than a "big bang" approach.
Phase 1 focuses on replacing the router dependency with Cloudflare Tunnels, eliminating port
forwarding while maintaining 100% compatibility. This approach was validated through community
discussions and Unraid-specific research, confirming that cloudflared containers work reliably on
Unraid using Community Applications templates. The Cloudflare tunnel approach provides better
security (no open ports), easier management, and prepares the infrastructure for the subsequent
Kubernetes ingress insertion in Phase 2.

## Current State

- Host: Nezuko (Unraid), Domain: dailey.app, SWAG on port 443
- Router: UDMP forwarding 443 → nezuko:443
- Goal: Replace port forwarding with Cloudflared tunnel

## Implementation

1. **Create tunnel**: Cloudflare Zero Trust → Networks → Tunnels → homelab-tunnel
2. **Deploy on Unraid**:
   - Apps → Search "cloudflared" → aeleos template
   - Post Arguments: `tunnel --no-autoupdate run --token YOUR_TOKEN_HERE`
   - Host Path: `/mnt/user/appdata/cloudflared`
   - Container Path: `/home/nonroot/.cloudflared`
3. **Configure routing**: `*.dailey.app` → `https://192.168.1.58:443`
4. **SSL settings**: Full (strict), HSTS enabled
5. **Cutover**: Test, then disable port forwarding

## Validation Checklist

- [ ] cloudflared container running in Unraid Docker
- [ ] All services accessible via `*.dailey.app`
- [ ] SSL certificates working (Cloudflare-managed)
- [ ] Router port forwarding disabled
- [ ] Tunnel shows "Healthy" in Cloudflare dashboard
- [ ] Container auto-starts with Unraid

## Next Action

Deploy cloudflared container on Unraid with tunnel token from Cloudflare dashboard.
