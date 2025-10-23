#!/bin/bash
set -e

echo "==================================="
echo "Fixing GitHub Pages Helm Repository"
echo "==================================="
echo ""

# Get chart info from main branch
CHART_DIR="helm/multi-platform-demo"
CHART_VERSION=$(grep '^version:' $CHART_DIR/Chart.yaml | awk '{print $2}')
CHART_NAME=$(grep '^name:' $CHART_DIR/Chart.yaml | awk '{print $2}')
APP_VERSION=$(grep '^appVersion:' $CHART_DIR/Chart.yaml | awk '{print $2}' | tr -d '"')
DESCRIPTION=$(grep '^description:' $CHART_DIR/Chart.yaml | cut -d' ' -f2-)
CREATED=$(date -u +"%Y-%m-%dT%H:%M:%S.000000000Z")

echo "Chart: $CHART_NAME"
echo "Version: $CHART_VERSION"
echo "App Version: $APP_VERSION"
echo ""

# Create index.yaml content
INDEX_CONTENT="apiVersion: v1
entries:
  $CHART_NAME:
  - apiVersion: v2
    appVersion: \"$APP_VERSION\"
    created: \"$CREATED\"
    description: $DESCRIPTION
    name: $CHART_NAME
    type: application
    urls:
    - https://github.com/Xiliath/multi-platform-demo/releases/download/$CHART_NAME-$CHART_VERSION/$CHART_NAME-$CHART_VERSION.tgz
    version: $CHART_VERSION
generated: \"$CREATED\""

echo "Switching to gh-pages branch..."
git checkout gh-pages
echo ""

# Update index.yaml
echo "$INDEX_CONTENT" > index.yaml
echo "✓ Created index.yaml:"
cat index.yaml
echo ""

# Copy landing page from main branch
echo "Updating landing page..."
git checkout claude/github-helm-release-011CUQPE6e3JT3NxbRKR294R -- docs/index.html
if [ -f docs/index.html ]; then
    mv docs/index.html index.html
    rm -rf docs
    echo "✓ Updated landing page"
else
    echo "⚠ Landing page not found, keeping existing"
fi
echo ""

# Commit changes
git add index.yaml index.html
if git diff --staged --quiet; then
    echo "No changes to commit"
    git checkout -
else
    echo "Committing changes..."
    git commit -m "Update Helm repository index and landing page for v$CHART_VERSION"
    echo ""

    echo "Pushing to gh-pages..."
    git push origin gh-pages
    echo ""

    echo "==================================="
    echo "✓ Successfully fixed gh-pages!"
    echo "==================================="
    echo ""
    echo "Your Helm repository is now live at:"
    echo "  https://xiliath.github.io/multi-platform-demo"
    echo ""
    echo "Test it with:"
    echo "  helm repo add multi-platform https://xiliath.github.io/multi-platform-demo"
    echo "  helm repo update"
    echo "  helm search repo multi-platform"
    echo "  helm install my-demo multi-platform/multi-platform-demo"
    echo ""

    # Switch back to previous branch
    git checkout -
fi
