# Multi-Platform Demo - Helm Chart

This Helm chart deploys the multi-platform Hello World application with collaborative canvas to Kubernetes.

## Architecture

The application consists of:
- **6 Platform Services**: .NET, Node.js, Python, Java, Go, Rust (ports 5000-5005)
- **WebSocket Server**: Real-time collaboration (port 8081)
- **Nginx Load Balancer**: Reverse proxy and routing (ports 80, 8081)

## Prerequisites

1. Kubernetes cluster running (Docker Desktop, Minikube, kind, etc.)
2. Helm 3.x installed
3. kubectl configured to access your cluster

## Installation

### Quick Install (Recommended)

**1. Add the Helm repository:**
```bash
helm repo add multi-platform https://xiliath.github.io/multi-platform-demo
helm repo update
```

**2. Install the chart:**

For **cloud Kubernetes** (AWS EKS, Google GKE, Azure AKS):
```bash
helm install my-demo multi-platform/multi-platform-demo
```

For **desktop Kubernetes** (Docker Desktop, Minikube, kind):
```bash
helm install my-demo multi-platform/multi-platform-demo \
  --set nginx.service.type=NodePort
```

Or with custom values file:
```bash
helm install my-demo multi-platform/multi-platform-demo -f custom-values.yaml
```

### Install from Source (For Development)

If you're developing locally and want to test changes:

```bash
# Clone the repository
git clone https://github.com/Xiliath/multi-platform-demo.git
cd multi-platform-demo

# Install from local chart
helm install my-demo ./helm/multi-platform-demo
```

**Note**: Images are automatically pulled from GitHub Container Registry (ghcr.io). You don't need to build them locally.

### Access the Application

**Get the LoadBalancer IP/Port:**
```bash
kubectl get service my-demo-nginx
```

For LoadBalancer type (default on cloud):
- Wait for EXTERNAL-IP to be assigned
- Access: `http://<EXTERNAL-IP>`

For NodePort (default on desktop):
```bash
kubectl get service my-demo-nginx -o jsonpath='{.spec.ports[0].nodePort}'
```
- Access: `http://localhost:<NODE-PORT>`

For port-forward (alternative):
```bash
kubectl port-forward service/my-demo-nginx 8080:80 8081:8081
```
- Access: `http://localhost:8080`

## Configuration

### Custom Values

Create a `custom-values.yaml` file to override default values:

```yaml
# Example: Increase resources for Java service
java:
  resources:
    limits:
      cpu: 2000m
      memory: 2Gi
    requests:
      cpu: 1000m
      memory: 1Gi

# Example: Use NodePort instead of LoadBalancer
nginx:
  service:
    type: NodePort
```

### Available Configuration Options

See `helm/multi-platform-demo/values.yaml` for all configurable values.

Key configurations:
- `replicaCount`: Number of pod replicas per service
- `image.repository`: Docker image repository
- `image.tag`: Docker image tag
- `resources`: CPU and memory limits/requests
- `service.type`: Kubernetes service type (LoadBalancer, NodePort, ClusterIP)

## Upgrading

To upgrade an existing release:

```bash
helm upgrade my-demo multi-platform/multi-platform-demo
```

Or from local source:
```bash
helm upgrade my-demo ./helm/multi-platform-demo
```

## Uninstalling

To remove the deployment:

```bash
helm uninstall my-demo
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -l app.kubernetes.io/instance=my-demo
```

### View Pod Logs
```bash
# Replace "my-demo" with your release name if different
kubectl logs -l app=my-demo-dotnet
kubectl logs -l app=my-demo-nodejs
kubectl logs -l app=my-demo-python
kubectl logs -l app=my-demo-java
kubectl logs -l app=my-demo-go
kubectl logs -l app=my-demo-rust
kubectl logs -l app=my-demo-websocket
kubectl logs -l app=my-demo-nginx
```

### Check Service Endpoints
```bash
kubectl get endpoints
```

### ImagePullBackOff Errors
If you see ImagePullBackOff errors:
1. Check images are public: https://github.com/orgs/xiliath/packages
2. Verify internet connectivity from your cluster
3. Check if images exist: `docker pull ghcr.io/xiliath/multi-platform-dotnet:1.1.1`

### WebSocket Connection Issues
Ensure:
1. Both ports 80 and 8081 are exposed on nginx service
2. WebSocket service is running: `kubectl get pods -l app=my-demo-websocket`
3. Check nginx logs: `kubectl logs -l app=my-demo-nginx`

## Development

### Testing Chart Changes

Render templates without installing:
```bash
helm template test-release ./helm/multi-platform-demo
```

Validate chart:
```bash
helm lint ./helm/multi-platform-demo
```

Debug installation:
```bash
helm install my-demo ./helm/multi-platform-demo --debug --dry-run
```

## Architecture Details

### Service Communication

```
Internet → Nginx LoadBalancer (80, 8081)
    ├─ / → .NET Service (5000)
    ├─ /nodejs → Node.js Service (5001)
    ├─ /python → Python Service (5002)
    ├─ /java → Java Service (5003)
    ├─ /go → Go Service (5004)
    ├─ /rust → Rust Service (5005)
    ├─ /canvas → .NET Canvas (5000)
    ├─ /nodejs/canvas → Node.js Canvas (5001)
    ├─ /python/canvas → Python Canvas (5002)
    ├─ /java/canvas → Java Canvas (5003)
    ├─ /go/canvas → Go Canvas (5004)
    ├─ /rust/canvas → Rust Canvas (5005)
    └─ /ws (8081) → WebSocket Service (8081)
```

All services are ClusterIP type and only accessible through the nginx LoadBalancer.

### Resource Allocation

Default resource requests/limits per service:
- **.NET, Node.js, Python, Go, Rust, WebSocket**: 250m/256Mi → 500m/512Mi
- **Java**: 500m/512Mi → 1000m/1Gi (higher due to JVM)
- **Nginx**: 250m/256Mi → 500m/512Mi

Total cluster requirements:
- **CPU**: ~3 cores (requests) / ~6 cores (limits)
- **Memory**: ~3GB (requests) / ~6GB (limits)
