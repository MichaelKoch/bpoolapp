# User Story: Kubernetes Deployment with Helm Chart for bpoolapp-mde

## Description
As a DevOps engineer, I want to deploy the bpoolapp container to a Kubernetes cluster in West Europe so that the application is accessible via the configured ingress route and benefits from cloud-native deployment and scaling capabilities. The application must also serve digital asset links via the `.well-known/assetlinks.json` endpoint to support app linking and verification standards.

## Acceptance Criteria

### Kubernetes Infrastructure
- [ ] Application is deployed to a Kubernetes cluster located in West Europe (Azure - Amsterdam region)

### Helm Chart Deployment
- [ ] A Helm chart is created/configured for the bpoolapp application
- [ ] Helm chart includes all necessary Kubernetes manifests:
  - [ ] Deployment manifest with container specifications
  - [ ] Service manifest for internal communication
  - [ ] ConfigMap for environment-specific configuration
  - [ ] Secrets management for sensitive data

### Ingress Route Configuration
- [ ] Ingress resource is configured with hostname: `[bpoolapp-mde].hugoboss.com`
- [ ] Ingress routing rules correctly direct traffic to the bpoolapp service

### Web Assets & Digital Links
- [ ] `.well-known/assetlinks.json` file is created and properly configured
- [ ] `assetlinks.json` is accessible at `https://[bpoolapp-mde].hugoboss.com/.well-known/assetlinks.json`
- [ ] File contains valid JSON with correct digital asset link declarations
- [ ] Proper HTTP headers (Content-Type: application/json) are served with the file
- [ ] File is included in the container image or mounted via ConfigMap

### Testing & Validation
- [ ] Application is accessible and responsive via the ingress route
- [ ] Application functionality works correctly in the Kubernetes environment
- [ ] Performance is acceptable for expected user load
- [ ] Monitoring and alerting are configured for production visibility

## Technical Details

| Aspect | Value |
|--------|-------|
| **Region** | West Europe (Azure - Amsterdam) |
| **Ingress Domain** | [bpoolapp-mde].hugoboss.com |
| **Deployment Method** | Helm Chart |
| **Protocol** | HTTPS |
| **Container Registry** | [To be specified] |

## Definition of Done
- [ ] Code review completed and approved
- [ ] All acceptance criteria met and verified
- [ ] Documentation is complete
- [ ] Production deployment successful
- [ ] Monitoring and alerting verified

## assetlinks.json Content

The `.well-known/assetlinks.json` file should be placed in the application serving path and contain digital asset link declarations. Example structure:


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
- Accessible without authentication
- Properly configured for app-to-site linking verification
