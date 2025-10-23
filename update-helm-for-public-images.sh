#!/bin/bash
set -e

REGISTRY="ghcr.io"
OWNER="xiliath"  # Change this to your GitHub username/org

echo "Updating Helm values to use public images..."

# Update values.yaml
VALUES_FILE="helm/multi-platform-demo/values.yaml"

sed -i "s|repository: multi-platform-dotnet|repository: $REGISTRY/$OWNER/multi-platform-dotnet|g" $VALUES_FILE
sed -i "s|repository: multi-platform-nodejs|repository: $REGISTRY/$OWNER/multi-platform-nodejs|g" $VALUES_FILE
sed -i "s|repository: multi-platform-python|repository: $REGISTRY/$OWNER/multi-platform-python|g" $VALUES_FILE
sed -i "s|repository: multi-platform-java|repository: $REGISTRY/$OWNER/multi-platform-java|g" $VALUES_FILE
sed -i "s|repository: multi-platform-go|repository: $REGISTRY/$OWNER/multi-platform-go|g" $VALUES_FILE
sed -i "s|repository: multi-platform-rust|repository: $REGISTRY/$OWNER/multi-platform-rust|g" $VALUES_FILE
sed -i "s|repository: multi-platform-websocket|repository: $REGISTRY/$OWNER/multi-platform-websocket|g" $VALUES_FILE

# Update values-desktop.yaml if it exists
if [ -f "helm/values-desktop.yaml" ]; then
    echo "Note: values-desktop.yaml uses local values - keeping as is for development"
fi

# Update chart version for new release
CHART_FILE="helm/multi-platform-demo/Chart.yaml"
sed -i "s|version: 1.1.0|version: 1.1.1|g" $CHART_FILE

# Update CHANGELOG
CHANGELOG="helm/multi-platform-demo/CHANGELOG.md"
sed -i "3a\\
## [1.1.1] - $(date +%Y-%m-%d)\\
\\
### Changed\\
- Updated all image repositories to use GitHub Container Registry (ghcr.io)\\
- Images are now publicly available for easy installation\\
- No need to build images locally anymore\\
\\
" $CHANGELOG

echo "✓ Updated Helm chart to use public images"
echo ""
echo "Review the changes:"
echo "  git diff $VALUES_FILE"
echo ""
echo "Then commit and push:"
echo "  git add $VALUES_FILE $CHART_FILE $CHANGELOG"
echo "  git commit -m 'Use public container registry images'"
echo "  git push"
echo ""
