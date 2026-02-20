# User Story: Azure Blob Storage with Traefik Routing for bpoolapp-mde Assets

## Description
As a DevOps engineer, I want to host the digital asset files (`.well-known/assetlinks.json`) on Azure Blob Storage instead of deploying them within a Kubernetes pod so that asset serving is decoupled from application compute, reducing pod resource consumption and improving asset availability. The assets must remain accessible via the same configured ingress route using Traefik routing rules to ensure seamless integration with existing infrastructure.

## Acceptance Criteria

### Azure Blob Storage Setup
- [ ] Azure Storage Account is created in West Europe (Amsterdam region)
- [ ] Blob container is created for storing digital asset files
- [ ] Container is configured for static web hosting (read-only public access)
- [ ] `.well-known/assetlinks.json` is uploaded to the blob container
- [ ] CORS policies are properly configured on the storage account if needed
- [ ] Container naming follows organizational standards

### Traefik Route Configuration
- [ ] Traefik IngressRoute or Ingress resource is configured to intercept requests to `/.well-known/*` paths
- [ ] Requests matching `/.well-known/assetlinks.json` are routed to the Azure Blob Storage endpoint
- [ ] Route maintains the hostname: `[bpoolapp-mde].hugoboss.com`
- [ ] Application traffic continues to route to the bpoolapp Kubernetes service
- [ ] Middleware is configured for proper header management (Content-Type: application/json)

### DNS and Endpoint Configuration
- [ ] Azure Storage Blob endpoint is securely accessible (HTTPS)
- [ ] Optional: Custom domain DNS CNAME is configured if using custom domain for blob storage
- [ ] Traefik routing rules correctly distinguish between app routes and asset routes

### Web Assets & Digital Links
- [ ] `.well-known/assetlinks.json` file is created and properly configured in blob storage
- [ ] File is accessible at `https://[bpoolapp-mde].hugoboss.com/.well-known/assetlinks.json`
- [ ] File contains valid JSON with correct digital asset link declarations
- [ ] Proper HTTP headers (Content-Type: application/json) are served with the file
- [ ] File is NOT embedded in the container image

### Testing & Validation
- [ ] Application is accessible via the ingress route and routes to bpoolapp service
- [ ] Assets are accessible via the ingress route and served from blob storage
- [ ] Asset file requests return correct Content-Type headers
- [ ] Application functionality works correctly with decoupled asset serving
- [ ] Performance is acceptable with blob storage latency
- [ ] Monitoring and alerting are configured for asset availability

## Technical Details

| Aspect | Value |
|--------|-------|
| **Region** | West Europe (Azure - Amsterdam) |
| **Ingress Domain** | [bpoolapp-mde].hugoboss.com |
| **Asset Storage** | Azure Blob Storage |
| **Routing Method** | Traefik IngressRoute |
| **Protocol** | HTTPS |
| **Asset Path** | `/.well-known/assetlinks.json` |
| **Container Service** | Kubernetes with Traefik |

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│         Client Request                                  │
│   https://[bpoolapp-mde].hugoboss.com/...               │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │  Traefik Ingress Controller      │
        │  (Kubernetes Service)            │
        └──────────────┬───────────────────┘
                       │
         ┌─────────────┴──────────────┐
         │                            │
    /.well-known/*              /api/* or others
         │                            │
         ▼                            ▼
    ┌─────────────────┐      ┌──────────────────┐
    │ Azure Blob      │      │ bpoolapp K8s Pod │
    │ Storage         │      │ (Service)        │
    │ assetlinks.json │      │                  │
    └─────────────────┘      └──────────────────┘
```

## Traefik Configuration Example

### IngressRoute Definition
```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: bpoolapp-mde-assets
  namespace: default
spec:
  entryPoints:
    - websecure
  routes:
    # Asset route to Azure Blob Storage
    - match: Host(`[bpoolapp-mde].hugoboss.com`) && PathPrefix(`/.well-known`)
      kind: Rule
      services:
        - name: azure-blob-storage
          port: 443
      middlewares:
        - name: asset-headers
    # Application route to bpoolapp service
    - match: Host(`[bpoolapp-mde].hugoboss.com`)
      kind: Rule
      services:
        - name: bpoolapp-service
          port: 8080
  tls:
    certResolver: letsencrypt
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: asset-headers
spec:
  headers:
    customResponseHeaders:
      Content-Type: "application/json"
      Cache-Control: "public, max-age=3600"
```

### Alternative: Using Ingress with Annotations
If using standard Kubernetes Ingress with Traefik provider:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: bpoolapp-mde
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
spec:
  rules:
    - host: [bpoolapp-mde].hugoboss.com
      http:
        paths:
          # Assets from blob storage
          - path: /.well-known/assetlinks.json
            pathType: Exact
            backend:
              service:
                name: azure-blob-storage
                port:
                  number: 443
          # Application traffic
          - path: /
            pathType: Prefix
            backend:
              service:
                name: bpoolapp-service
                port:
                  number: 8080
```

## assetlinks.json Content

The `.well-known/assetlinks.json` file should be uploaded to Azure Blob Storage and contain digital asset link declarations. Example structure:

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

**Note:** Replace the SHA256 certificate fingerprint with the actual fingerprint of the app's signing certificate. The file must be:
- Valid JSON format
- Served with `Content-Type: application/json` header
- Uploaded to Azure Blob Storage (not in container)
- Accessible without authentication (public blob)
- Properly routed via Traefik

## Definition of Done
- [ ] Azure Storage Account created and configured
- [ ] Blob container set up with public read access
- [ ] assetlinks.json uploaded to blob storage
- [ ] Traefik routing rules implemented and tested
- [ ] Path-based routing correctly distinguishes assets from app traffic
- [ ] HTTPS/TLS configured for all routes
- [ ] Code review completed and approved
- [ ] All acceptance criteria met and verified
- [ ] Documentation is complete
- [ ] Production deployment successful
- [ ] Monitoring and alerting verified for asset availability

## Benefits

- **Reduced Pod Overhead:** Asset serving doesn't consume pod compute resources
- **Scalability:** Blob storage scales independently from application pods
- **Cost Efficiency:** Separation of concerns allows cost optimization per component
- **High Availability:** Azure Blob Storage provides built-in redundancy and availability
- **Simplified Updates:** Assets can be updated without redeploying application pods
- **Clear Separation:** Infrastructure clearly separates static assets from dynamic application logic
