#!/bin/bash
set -e

echo "==================================="
echo "Helm Chart Testing"
echo "==================================="
echo ""

CHART_DIR="./helm/multi-platform-demo"

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "Error: Helm is not installed. Please install Helm 3.x first."
    exit 1
fi

echo "Testing chart in: $CHART_DIR"
echo ""

# Step 1: Lint the chart
echo "1. Running helm lint..."
helm lint $CHART_DIR
echo "✓ Lint passed"
echo ""

# Step 2: Validate template rendering
echo "2. Validating template rendering..."
helm template test-release $CHART_DIR > /dev/null
echo "✓ Template rendering succeeded"
echo ""

# Step 3: Show rendered templates (dry-run)
echo "3. Showing dry-run output (first 50 lines)..."
helm install test-release $CHART_DIR --dry-run --debug | head -50
echo ""
echo "... (output truncated)"
echo ""

# Step 4: Check Chart.yaml version
echo "4. Checking chart version..."
CHART_VERSION=$(grep '^version:' $CHART_DIR/Chart.yaml | awk '{print $2}')
echo "Chart version: $CHART_VERSION"
echo ""

# Step 5: Check for CHANGELOG entry
echo "5. Checking CHANGELOG..."
if [ -f "$CHART_DIR/CHANGELOG.md" ]; then
    if grep -q "\[$CHART_VERSION\]" "$CHART_DIR/CHANGELOG.md"; then
        echo "✓ CHANGELOG has entry for version $CHART_VERSION"
    else
        echo "⚠ Warning: CHANGELOG.md doesn't have entry for version $CHART_VERSION"
        echo "  Please update CHANGELOG.md before releasing"
    fi
else
    echo "⚠ Warning: CHANGELOG.md not found"
fi
echo ""

# Step 6: Package the chart
echo "6. Packaging chart..."
PACKAGE_OUTPUT=$(helm package $CHART_DIR)
PACKAGE_FILE=$(echo $PACKAGE_OUTPUT | awk '{print $NF}')
echo "✓ Chart packaged: $PACKAGE_FILE"
echo ""

# Step 7: Verify package contents
echo "7. Verifying package contents..."
tar -tzf "$PACKAGE_FILE" | head -20
echo "... (output truncated)"
echo ""

# Cleanup
rm -f "$PACKAGE_FILE"
echo "Cleaned up package file"
echo ""

echo "==================================="
echo "All Tests Passed!"
echo "==================================="
echo ""
echo "Chart is ready for release."
echo ""
echo "To release:"
echo "1. Commit your changes"
echo "2. Push to main branch"
echo "3. GitHub Actions will automatically release"
echo ""
echo "Or manually:"
echo "  helm package $CHART_DIR"
echo "  # Upload .tgz to GitHub Releases"
echo ""
