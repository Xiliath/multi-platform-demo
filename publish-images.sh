#!/bin/bash
set -e

REGISTRY="ghcr.io"
OWNER="xiliath"  # Change this to your GitHub username/org

echo "==================================="
echo "Publishing Images to GitHub Container Registry"
echo "==================================="
echo ""

# Check if logged in
if ! docker info | grep -q "Username"; then
    echo "Please login to GitHub Container Registry first:"
    echo "  echo \$GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin"
    echo ""
    echo "Create a token at: https://github.com/settings/tokens"
    echo "Needed scopes: write:packages, read:packages"
    exit 1
fi

echo "Building and pushing all images to $REGISTRY/$OWNER..."
echo ""

# Build and push each image
for service in dotnet nodejs python java go rust websocket; do
    IMAGE="multi-platform-$service"
    FULL_IMAGE="$REGISTRY/$OWNER/$IMAGE:latest"

    echo "📦 Building $IMAGE..."
    if [ "$service" = "websocket" ]; then
        docker build -f websocket/Dockerfile -t $IMAGE:latest .
    else
        docker build -f $service/Dockerfile -t $IMAGE:latest .
    fi

    echo "🚀 Pushing $FULL_IMAGE..."
    docker tag $IMAGE:latest $FULL_IMAGE
    docker push $FULL_IMAGE

    echo "✓ Published $FULL_IMAGE"
    echo ""
done

echo "==================================="
echo "All images published successfully!"
echo "==================================="
echo ""
echo "Images available at:"
echo "  $REGISTRY/$OWNER/multi-platform-dotnet:latest"
echo "  $REGISTRY/$OWNER/multi-platform-nodejs:latest"
echo "  $REGISTRY/$OWNER/multi-platform-python:latest"
echo "  $REGISTRY/$OWNER/multi-platform-java:latest"
echo "  $REGISTRY/$OWNER/multi-platform-go:latest"
echo "  $REGISTRY/$OWNER/multi-platform-rust:latest"
echo "  $REGISTRY/$OWNER/multi-platform-websocket:latest"
echo ""
echo "Now update Helm chart to use these images:"
echo "  ./update-helm-for-public-images.sh"
echo ""
