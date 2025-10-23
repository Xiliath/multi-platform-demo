#!/bin/bash
set -e

REGISTRY="ghcr.io"
OWNER="xiliath"  # Change this to your GitHub username/org
VERSION="1.1.0"   # Should match Helm chart version

echo "==================================="
echo "Publishing Images to GitHub Container Registry"
echo "Version: $VERSION"
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
    FULL_IMAGE="$REGISTRY/$OWNER/$IMAGE"

    echo "📦 Building $IMAGE..."
    if [ "$service" = "websocket" ]; then
        docker build -f websocket/Dockerfile -t $IMAGE:$VERSION .
    else
        docker build -f $service/Dockerfile -t $IMAGE:$VERSION .
    fi

    echo "🚀 Pushing $FULL_IMAGE:$VERSION and $FULL_IMAGE:latest..."
    docker tag $IMAGE:$VERSION $FULL_IMAGE:$VERSION
    docker tag $IMAGE:$VERSION $FULL_IMAGE:latest
    docker push $FULL_IMAGE:$VERSION
    docker push $FULL_IMAGE:latest

    echo "✓ Published $FULL_IMAGE:$VERSION"
    echo ""
done

echo "==================================="
echo "All images published successfully!"
echo "==================================="
echo ""
echo "Images available at:"
echo "  $REGISTRY/$OWNER/multi-platform-dotnet:$VERSION (and :latest)"
echo "  $REGISTRY/$OWNER/multi-platform-nodejs:$VERSION (and :latest)"
echo "  $REGISTRY/$OWNER/multi-platform-python:$VERSION (and :latest)"
echo "  $REGISTRY/$OWNER/multi-platform-java:$VERSION (and :latest)"
echo "  $REGISTRY/$OWNER/multi-platform-go:$VERSION (and :latest)"
echo "  $REGISTRY/$OWNER/multi-platform-rust:$VERSION (and :latest)"
echo "  $REGISTRY/$OWNER/multi-platform-websocket:$VERSION (and :latest)"
echo ""
echo "Now update Helm chart to use these images:"
echo "  ./update-helm-for-public-images.sh"
echo ""
