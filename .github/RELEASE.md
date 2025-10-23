# Helm Chart Release Process

This document describes how Helm charts are released for the Multi-Platform Demo project.

## Overview

We use GitHub Actions and the [chart-releaser-action](https://github.com/helm/chart-releaser-action) to automatically package and release Helm charts to GitHub Releases and GitHub Pages.

## How It Works

1. **Trigger**: When changes are pushed to the `main` branch that affect files in the `helm/` directory
2. **Package**: The chart is packaged into a `.tgz` file
3. **Release**: A GitHub Release is created with the chart package
4. **Publish**: The chart is added to the Helm repository index and published to GitHub Pages
5. **Access**: Users can add the repository and install charts

## Helm Repository URL

```bash
https://xiliath.github.io/multi-platform-demo
```

## Release Workflow

### Automatic Release (Recommended)

1. **Update Chart Version**: Edit `helm/multi-platform-demo/Chart.yaml` and increment the version:
   ```yaml
   version: 1.0.1  # Increment this
   ```

2. **Update Changelog**: Add entry to `helm/multi-platform-demo/CHANGELOG.md`:
   ```markdown
   ## [1.0.1] - 2025-10-24
   ### Fixed
   - Fixed issue with...
   ```

3. **Merge to Main**: Create a PR and merge to `main` branch

4. **Automatic Process**:
   - GitHub Actions workflow triggers
   - Chart is packaged
   - GitHub Release is created
   - Chart is published to GitHub Pages
   - Users can install: `helm repo update && helm install ...`

### Manual Release

If needed, you can manually create a release:

1. **Package the chart**:
   ```bash
   helm package helm/multi-platform-demo
   ```

2. **Create GitHub Release**:
   - Go to GitHub Releases
   - Create new release with tag matching chart version (e.g., `multi-platform-demo-1.0.1`)
   - Upload the `.tgz` package

3. **Update repository index**:
   ```bash
   helm repo index . --url https://xiliath.github.io/multi-platform-demo
   ```

## Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.x.x): Incompatible API changes
- **MINOR** (x.1.x): New functionality in a backward compatible manner
- **PATCH** (x.x.1): Backward compatible bug fixes

## Testing Before Release

Always test the chart before releasing:

```bash
# Lint the chart
helm lint helm/multi-platform-demo

# Dry-run installation
helm install test-release helm/multi-platform-demo --dry-run --debug

# Template rendering
helm template test-release helm/multi-platform-demo

# Install to test cluster
helm install test-release helm/multi-platform-demo
```

## GitHub Pages Setup

The Helm repository is hosted on GitHub Pages:

1. **Enable GitHub Pages**:
   - Go to repository Settings > Pages
   - Source: Deploy from a branch
   - Branch: `gh-pages` (created automatically by workflow)
   - Or: GitHub Actions (if using actions deploy)

2. **Verify**: Visit https://xiliath.github.io/multi-platform-demo

## Workflow Configuration

The release workflow is defined in `.github/workflows/release-helm-chart.yml`:

- **Triggers**: Push to `main` branch with changes in `helm/**`
- **Permissions**: `contents: write`, `pages: write`
- **Tools**: Helm 3.14.0, chart-releaser-action v1.6.0

## Chart Repository Configuration

Configuration is in `.github/cr.yaml`:

```yaml
owner: Xiliath
git-repo: multi-platform-demo
charts-repo-url: https://xiliath.github.io/multi-platform-demo
```

## Using Released Charts

Once released, users can install charts:

```bash
# Add repository
helm repo add multi-platform https://xiliath.github.io/multi-platform-demo

# Update repositories
helm repo update

# Search for charts
helm search repo multi-platform

# Install chart
helm install my-demo multi-platform/multi-platform-demo

# Install specific version
helm install my-demo multi-platform/multi-platform-demo --version 1.0.0
```

## Troubleshooting

### Release Failed

- Check GitHub Actions workflow logs
- Verify chart passes `helm lint`
- Ensure version was incremented in Chart.yaml
- Check for YAML syntax errors

### Chart Not Showing in Repository

- Verify GitHub Pages is enabled
- Check that index.yaml was generated
- Wait a few minutes for GitHub Pages to update
- Clear Helm cache: `helm repo update`

### Version Conflicts

- Ensure Chart.yaml version is unique
- Don't reuse version numbers
- Delete failed releases if needed

## Best Practices

1. **Always increment version** when making changes
2. **Update CHANGELOG.md** for every release
3. **Test thoroughly** before merging to main
4. **Use semantic versioning** consistently
5. **Document breaking changes** clearly
6. **Keep chart backward compatible** when possible

## Contact

For questions about releases, open an issue on GitHub.
