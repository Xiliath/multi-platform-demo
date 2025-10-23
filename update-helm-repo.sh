#!/bin/bash
set -e

echo "==================================="
echo "Manually Updating Helm Repository"
echo "==================================="
echo ""

CHART_DIR="helm/multi-platform-demo"
REPO_URL="https://xiliath.github.io/multi-platform-demo"
RELEASE_URL="https://github.com/Xiliath/multi-platform-demo/releases/download"

# Get chart version
CHART_VERSION=$(grep '^version:' $CHART_DIR/Chart.yaml | awk '{print $2}')
CHART_NAME=$(grep '^name:' $CHART_DIR/Chart.yaml | awk '{print $2}')
APP_VERSION=$(grep '^appVersion:' $CHART_DIR/Chart.yaml | awk '{print $2}' | tr -d '"')
DESCRIPTION=$(grep '^description:' $CHART_DIR/Chart.yaml | cut -d' ' -f2-)

echo "Chart: $CHART_NAME"
echo "Version: $CHART_VERSION"
echo "App Version: $APP_VERSION"
echo ""

# Package the chart
echo "Packaging chart..."
helm package $CHART_DIR -d /tmp
PACKAGE_FILE="/tmp/$CHART_NAME-$CHART_VERSION.tgz"
echo "✓ Packaged: $PACKAGE_FILE"
echo ""

# Calculate SHA256
DIGEST=$(sha256sum $PACKAGE_FILE | awk '{print $1}')
echo "SHA256: $DIGEST"
echo ""

# Get file size and created time
FILE_SIZE=$(stat -c%s "$PACKAGE_FILE")
CREATED=$(date -u +"%Y-%m-%dT%H:%M:%S.%NZ")

# Create index.yaml
echo "Creating index.yaml..."
cat > /tmp/index.yaml <<EOF
apiVersion: v1
entries:
  $CHART_NAME:
  - apiVersion: v2
    appVersion: $APP_VERSION
    created: "$CREATED"
    description: $DESCRIPTION
    digest: $DIGEST
    name: $CHART_NAME
    type: application
    urls:
    - $RELEASE_URL/$CHART_NAME-$CHART_VERSION/$CHART_NAME-$CHART_VERSION.tgz
    version: $CHART_VERSION
generated: "$CREATED"
EOF

echo "✓ Created index.yaml"
cat /tmp/index.yaml
echo ""

# Switch to gh-pages branch
echo "Switching to gh-pages branch..."
git checkout gh-pages
echo ""

# Copy files
echo "Updating gh-pages files..."
cp /tmp/index.yaml index.yaml
cp docs/index.html index.html 2>/dev/null || echo "No docs/index.html found, keeping existing"
echo ""

# Show changes
echo "Changes to commit:"
git diff index.yaml
echo ""

# Commit and push
git add index.yaml index.html
if git diff --staged --quiet; then
    echo "No changes to commit"
else
    git commit -m "Update Helm repository index for $CHART_NAME $CHART_VERSION"
    echo ""
    echo "Pushing to gh-pages..."
    git push origin gh-pages
    echo ""
    echo "==================================="
    echo "✓ Successfully updated Helm repository!"
    echo "==================================="
    echo ""
    echo "Test it with:"
    echo "  helm repo add multi-platform $REPO_URL"
    echo "  helm repo update"
    echo "  helm search repo multi-platform"
    echo ""
fi

# Cleanup
rm -f $PACKAGE_FILE /tmp/index.yaml

# Switch back
PREV_BRANCH=$(git branch --show-current)
if [ "$PREV_BRANCH" != "gh-pages" ]; then
    git checkout -
fi
