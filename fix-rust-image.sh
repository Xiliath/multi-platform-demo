#!/bin/bash
set -e

echo "==================================="
echo "Quick Fix: Build Rust Image"
echo "==================================="
echo ""

# Build Rust image
echo "Building Rust image..."
docker build -f rust/Dockerfile -t multi-platform-rust:latest .

# Detect cluster type and load
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    echo "Loading into Minikube..."
    minikube image load multi-platform-rust:latest
elif command -v kind &> /dev/null && kind get clusters 2>/dev/null | grep -q .; then
    CLUSTER_NAME=$(kind get clusters | head -1)
    echo "Loading into kind cluster: $CLUSTER_NAME..."
    kind load docker-image multi-platform-rust:latest --name $CLUSTER_NAME
else
    echo "Docker Desktop detected - image automatically available"
fi

echo ""
echo "✓ Rust image ready!"
echo ""
echo "Now upgrade your Helm release:"
echo "  helm upgrade my-demo-for-me ./helm/multi-platform-demo"
echo ""
echo "Or if you used the Helm repo:"
echo "  helm repo update"
echo "  helm upgrade my-demo-for-me multi-platform/multi-platform-demo"
echo ""
