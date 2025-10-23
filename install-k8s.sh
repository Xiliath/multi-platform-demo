#!/bin/bash
set -e

echo "==================================="
echo "Multi-Platform Demo - Kubernetes Installation"
echo "==================================="
echo ""

# Step 1: Build images
echo "Step 1: Building Docker images..."
./build-k8s-images.sh
echo ""

# Step 2: Detect Kubernetes environment
echo "Step 2: Detecting Kubernetes environment..."
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    echo "Minikube detected. Loading images..."
    minikube image load multi-platform-dotnet:latest
    minikube image load multi-platform-nodejs:latest
    minikube image load multi-platform-python:latest
    minikube image load multi-platform-java:latest
    minikube image load multi-platform-go:latest
    minikube image load multi-platform-websocket:latest
    echo "Images loaded into Minikube."
elif command -v kind &> /dev/null && kind get clusters 2>/dev/null | grep -q .; then
    CLUSTER_NAME=$(kind get clusters | head -1)
    echo "kind cluster detected: $CLUSTER_NAME. Loading images..."
    kind load docker-image multi-platform-dotnet:latest --name $CLUSTER_NAME
    kind load docker-image multi-platform-nodejs:latest --name $CLUSTER_NAME
    kind load docker-image multi-platform-python:latest --name $CLUSTER_NAME
    kind load docker-image multi-platform-java:latest --name $CLUSTER_NAME
    kind load docker-image multi-platform-go:latest --name $CLUSTER_NAME
    kind load docker-image multi-platform-websocket:latest --name $CLUSTER_NAME
    echo "Images loaded into kind cluster."
else
    echo "Docker Desktop or other Kubernetes detected. Images should be automatically available."
fi
echo ""

# Step 3: Install Helm chart
echo "Step 3: Installing Helm chart..."
if helm list | grep -q "^multi-platform"; then
    echo "Existing installation found. Upgrading..."
    helm upgrade multi-platform ./helm/multi-platform-demo
else
    echo "Installing new release..."
    helm install multi-platform ./helm/multi-platform-demo
fi
echo ""

# Step 4: Wait for deployment
echo "Step 4: Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=multi-platform --timeout=300s || true
echo ""

# Step 5: Display access information
echo "==================================="
echo "Installation Complete!"
echo "==================================="
echo ""
echo "Getting service information..."
kubectl get service multi-platform-nginx
echo ""
echo "To access the application:"
echo "1. Check the EXTERNAL-IP of multi-platform-nginx service above"
echo "2. If it shows <pending>, use port-forward instead:"
echo "   kubectl port-forward service/multi-platform-nginx 8080:80 8081:8081"
echo "   Then access: http://localhost:8080"
echo ""
echo "To view logs:"
echo "  kubectl logs -l app=multi-platform-dotnet"
echo "  kubectl logs -l app=multi-platform-nodejs"
echo "  kubectl logs -l app=multi-platform-python"
echo "  kubectl logs -l app=multi-platform-java"
echo "  kubectl logs -l app=multi-platform-go"
echo "  kubectl logs -l app=multi-platform-websocket"
echo "  kubectl logs -l app=multi-platform-nginx"
echo ""
echo "To uninstall:"
echo "  helm uninstall multi-platform"
echo ""
