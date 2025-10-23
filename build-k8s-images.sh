#!/bin/bash
set -e

echo "Building Docker images for Kubernetes..."

# Build all images with proper tags
docker build -f dotnet/Dockerfile -t multi-platform-dotnet:latest .
docker build -f nodejs/Dockerfile -t multi-platform-nodejs:latest .
docker build -f python/Dockerfile -t multi-platform-python:latest .
docker build -f java/Dockerfile -t multi-platform-java:latest .
docker build -f go/Dockerfile -t multi-platform-go:latest .
docker build -f rust/Dockerfile -t multi-platform-rust:latest .
docker build -f websocket/Dockerfile -t multi-platform-websocket:latest .

echo "All images built successfully!"
echo ""
echo "To make these images available to your Kubernetes cluster:"
echo "1. For Docker Desktop: Images are automatically available"
echo "2. For Minikube: Run 'minikube image load <image-name>' for each image"
echo "3. For kind: Run 'kind load docker-image <image-name>' for each image"
echo "4. For remote registry: Tag and push to your registry"
