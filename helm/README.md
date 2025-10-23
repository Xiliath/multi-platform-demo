# Multi-Platform Demo - Helm Chart

This Helm chart deploys the multi-platform Hello World application with collaborative canvas to Kubernetes.

## Architecture

The application consists of:
- **5 Platform Services**: .NET, Node.js, Python, Java, Go (ports 5000-5004)
- **WebSocket Server**: Real-time collaboration (port 8081)
- **Nginx Load Balancer**: Reverse proxy and routing (ports 80, 8081)

## Prerequisites

1. Kubernetes cluster running (Docker Desktop, Minikube, kind, etc.)
2. Helm 3.x installed
3. kubectl configured to access your cluster
4. Docker images built locally

## Installation

### Step 1: Build Docker Images

From the project root directory, run:

```bash
chmod +x build-k8s-images.sh
./build-k8s-images.sh
```

### Step 2: Load Images into Kubernetes

**For Docker Desktop Kubernetes:**
Images are automatically available to the cluster.

**For Minikube:**
```bash
minikube image load multi-platform-dotnet:latest
minikube image load multi-platform-nodejs:latest
minikube image load multi-platform-python:latest
minikube image load multi-platform-java:latest
minikube image load multi-platform-go:latest
minikube image load multi-platform-websocket:latest
```

**For kind:**
```bash
kind load docker-image multi-platform-dotnet:latest
kind load docker-image multi-platform-nodejs:latest
kind load docker-image multi-platform-python:latest
kind load docker-image multi-platform-java:latest
kind load docker-image multi-platform-go:latest
kind load docker-image multi-platform-websocket:latest
```

### Step 3: Install the Helm Chart

```bash
helm install multi-platform ./helm/multi-platform-demo
```

Or with custom values:
```bash
helm install multi-platform ./helm/multi-platform-demo -f custom-values.yaml
```

### Step 4: Access the Application

**Get the LoadBalancer IP/Port:**
```bash
kubectl get service multi-platform-nginx
```

For LoadBalancer type (default):
- Wait for EXTERNAL-IP to be assigned
- Access: `http://<EXTERNAL-IP>`

For NodePort (if you changed service type):
```bash
kubectl get service multi-platform-nginx -o jsonpath='{.spec.ports[0].nodePort}'
```
- Access: `http://<NODE-IP>:<NODE-PORT>`

For port-forward (development):
```bash
kubectl port-forward service/multi-platform-nginx 8080:80
kubectl port-forward service/multi-platform-nginx 8081:8081
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
helm upgrade multi-platform ./helm/multi-platform-demo
```

## Uninstalling

To remove the deployment:

```bash
helm uninstall multi-platform
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -l app.kubernetes.io/instance=multi-platform
```

### View Pod Logs
```bash
kubectl logs -l app=multi-platform-dotnet
kubectl logs -l app=multi-platform-nodejs
kubectl logs -l app=multi-platform-python
kubectl logs -l app=multi-platform-java
kubectl logs -l app=multi-platform-go
kubectl logs -l app=multi-platform-websocket
kubectl logs -l app=multi-platform-nginx
```

### Check Service Endpoints
```bash
kubectl get endpoints
```

### ImagePullBackOff Errors
If you see ImagePullBackOff errors, ensure:
1. Images are built: `docker images | grep multi-platform`
2. Images are loaded into your cluster (see Step 2)
3. imagePullPolicy is set to `IfNotPresent` (default)

### WebSocket Connection Issues
Ensure:
1. Both ports 80 and 8081 are exposed on nginx service
2. WebSocket service is running: `kubectl get pods -l app=multi-platform-websocket`
3. Check nginx logs: `kubectl logs -l app=multi-platform-nginx`

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
helm install multi-platform ./helm/multi-platform-demo --debug --dry-run
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
    ├─ /canvas → .NET Canvas (5000)
    ├─ /nodejs/canvas → Node.js Canvas (5001)
    ├─ /python/canvas → Python Canvas (5002)
    ├─ /java/canvas → Java Canvas (5003)
    ├─ /go/canvas → Go Canvas (5004)
    └─ /ws (8081) → WebSocket Service (8081)
```

All services are ClusterIP type and only accessible through the nginx LoadBalancer.

### Resource Allocation

Default resource requests/limits per service:
- **.NET, Node.js, Python, Go, WebSocket**: 250m/256Mi → 500m/512Mi
- **Java**: 500m/512Mi → 1000m/1Gi (higher due to JVM)
- **Nginx**: 250m/256Mi → 500m/512Mi

Total cluster requirements:
- **CPU**: ~2.5 cores (requests) / ~5 cores (limits)
- **Memory**: ~2.5GB (requests) / ~5GB (limits)
