# Container Image Publishing

## Automated Publishing (Recommended)

Container images are **automatically built and published** via GitHub Actions when you push to the `main` branch.

### How It Works

The workflow `.github/workflows/publish-images.yml` automatically:
- Builds all 7 Docker images (dotnet, nodejs, python, java, go, rust, websocket)
- Publishes to GitHub Container Registry: `ghcr.io/xiliath/multi-platform-*`
- Tags with version from Chart.yaml appVersion (e.g., `1.1.1`) and `latest`
- No manual intervention required!

### Making Images Public

By default, GitHub Container Registry packages are private. To make them public so users can install:

1. Go to: https://github.com/users/YOUR_USERNAME/packages
2. For each image (`multi-platform-dotnet`, `multi-platform-nodejs`, etc.):
   - Click on the package
   - Click "Package settings"
   - Scroll to "Danger Zone"
   - Click "Change visibility" → "Public"

You only need to do this once per image.

## Manual Publishing (Advanced)

If you need to manually publish images for testing:

```bash
# Login to GitHub Container Registry
echo YOUR_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# Build and tag all images
docker compose build

# Tag and push each image (replace VERSION with your Chart.yaml appVersion)
VERSION="1.1.1"  # Should match helm/multi-platform-demo/Chart.yaml appVersion
for SERVICE in dotnet nodejs python java go rust websocket; do
  docker tag multi-platform-$SERVICE ghcr.io/YOUR_USERNAME/multi-platform-$SERVICE:$VERSION
  docker tag multi-platform-$SERVICE ghcr.io/YOUR_USERNAME/multi-platform-$SERVICE:latest
  docker push ghcr.io/YOUR_USERNAME/multi-platform-$SERVICE:$VERSION
  docker push ghcr.io/YOUR_USERNAME/multi-platform-$SERVICE:latest
done
```

**Note**: Create a Personal Access Token with `write:packages` scope at https://github.com/settings/tokens

## For Users Installing

Once images are published and public, users can install without building:

```bash
helm repo add multi-platform https://xiliath.github.io/multi-platform-demo
helm repo update
helm install my-demo multi-platform/multi-platform-demo
```

Images are automatically pulled from GitHub Container Registry!

## Troubleshooting

**Error: "unauthorized: unauthenticated"**
- Images are still private. Make them public in package settings.

**Error: "manifest unknown"**
- Images haven't been built yet. Push to `main` to trigger the workflow.

**Workflow not running?**
- Check: `.github/workflows/publish-images.yml` exists on `main` branch
- Check: GitHub Actions is enabled in repository settings
