# User Story: Serve bpoolapp-mde Digital Asset Links via Akamai + Azure Blob Storage (No Kubernetes/Traefik)

## Description
As a DevOps engineer, I want to host the digital asset file (`/.well-known/assetlinks.json`) in Azure Blob Storage and deliver it through Akamai CDN so that static asset delivery is fully decoupled from application runtime and does not depend on Kubernetes or Traefik routing.


## Acceptance Criteria

### Azure Blob Storage Setup
- [ ] Azure Storage Account is created in West Europe (Amsterdam region)
- [ ] Blob container is created for digital asset files
- [ ] Container access is configured for public read (or equivalent controlled anonymous read pattern)
- [ ] `.well-known/assetlinks.json` is uploaded in the correct path structure
- [ ] Blob endpoint serves the file over HTTPS
- [ ] CORS policy is configured only if required by consumers
- [ ] Storage naming follows organizational standards

### Akamai CDN Configuration
- [ ] Akamai property is configured for host `[bpoolapp-mde].hugoboss.com`
- [ ] Origin for `/.well-known/*` is Azure Blob Storage endpoint
- [ ] Akamai behavior/rule matches `/.well-known/assetlinks.json` (or `/.well-known/*` if future-proofing)
- [ ] `Content-Type: application/json` is preserved/forced for `assetlinks.json`
- [ ] Cache policy is configured (for example `max-age=3600`) with explicit purge strategy
- [ ] HTTPS is enforced end-to-end (edge + origin)

### DNS & TLS
- [ ] DNS points `[bpoolapp-mde].hugoboss.com` to Akamai edge hostname (CNAME)
- [ ] TLS certificate is valid for `[bpoolapp-mde].hugoboss.com`
- [ ] Direct blob endpoint is not exposed as the public canonical URL

### Web Asset & Digital Links
- [ ] `assetlinks.json` contains valid JSON digital asset link declarations
- [ ] File is reachable at `https://[bpoolapp-mde].hugoboss.com/.well-known/assetlinks.json`
- [ ] Response header includes `Content-Type: application/json`
- [ ] File is stored only in Blob Storage (not in container image/pod)

### Testing & Validation
- [ ] `curl -I https://[bpoolapp-mde].hugoboss.com/.well-known/assetlinks.json` returns `200 OK`
- [ ] Response includes correct `Content-Type`
- [ ] Akamai cache behavior is validated (HIT/MISS headers as configured)
- [ ] Fallback/error behavior is validated (origin unavailable scenario)
- [ ] Monitoring/alerting is configured for endpoint availability and non-200 responses

## Technical Details

| Aspect | Value |
|--------|-------|
| **Region** | West Europe (Azure - Amsterdam) |
| **Public Domain** | `[bpoolapp-mde].hugoboss.com` |
| **Edge/CDN** | Akamai |
| **Origin Storage** | Azure Blob Storage |
| **Protocol** | HTTPS |
| **Asset Path** | `/.well-known/assetlinks.json` |
| **Compute Dependency** | None (no K8s/Traefik) |

## Architecture Overview

```text
Client
  |
  v
https://[bpoolapp-mde].hugoboss.com/.well-known/assetlinks.json
  |
  v
Akamai Edge (CDN property + rule for /.well-known/*)
  |
  v
Azure Blob Storage Origin
  |
  v
.well-known/assetlinks.json
```

## Akamai Rule Intent (Conceptual)

- Match host: `[bpoolapp-mde].hugoboss.com`
- Match path: `/.well-known/assetlinks.json` (or `/.well-known/*`)
- Route to origin: Azure Blob Storage HTTPS endpoint
- Set/preserve response header: `Content-Type: application/json`
- Apply cache policy: short-to-medium TTL with purge support
- Enforce HTTPS and secure origin communication

## assetlinks.json Example

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.BPool.MobileApp",
      "sha256_cert_fingerprints": [
        "F7:CA:31:9B:9B:D4:4F:87:4D:17:B5:69:88:69:79:2A:D4:86:64:79:56:18:F8:98:71:05:B8:40:39:09:66:03"
      ]
    }
  }
]
```

Note: Replace fingerprint with the production signing certificate fingerprint.

## Definition of Done
- [ ] Azure Blob Storage is provisioned and hardened
- [ ] Akamai property/rules are configured and activated
- [ ] DNS/TLS is validated for `[bpoolapp-mde].hugoboss.com`
- [ ] `/.well-known/assetlinks.json` is publicly accessible via Akamai URL
- [ ] Correct headers and cache behavior are verified
- [ ] Runbook documents upload, purge, rollback, and validation steps
- [ ] Monitoring and alerting are active

## Benefits
- Removes Kubernetes and Traefik from static asset delivery path
- Improves reliability with CDN edge distribution
- Reduces operational complexity for `/.well-known` asset serving
- Enables independent asset updates via Blob upload + CDN purge
