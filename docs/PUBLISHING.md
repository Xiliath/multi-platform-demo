# Publishing Images to GitHub Container Registry

This guide shows how to publish container images so others can easily use them.

## Prerequisites

1. **GitHub Personal Access Token** with `write:packages` and `read:packages` scopes
   - Create at: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Select scopes: `write:packages`, `read:packages`
   - Copy the token

## Steps to Publish

### 1. Login to GitHub Container Registry

```bash
echo YOUR_GITHUB_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

### 2. Build and Publish All Images

```bash
./publish-images.sh
```

This will:
- Build all 7 Docker images
- Tag them for GitHub Container Registry
- Push to `ghcr.io/xiliath/multi-platform-*:latest`

**Note**: Edit `publish-images.sh` and change `OWNER="xiliath"` to your GitHub username first!

### 3. Update Helm Chart

```bash
./update-helm-for-public-images.sh
```

This automatically:
- Updates all image repositories in `values.yaml` to use `ghcr.io`
- Bumps chart version to 1.1.1
- Updates CHANGELOG

### 4. Make Images Public (Important!)

By default, GitHub Container Registry packages are private. Make them public:

1. Go to: https://github.com/users/YOUR_USERNAME/packages
2. For each image (`multi-platform-dotnet`, `multi-platform-nodejs`, etc.):
   - Click on the package
   - Click "Package settings"
   - Scroll to "Danger Zone"
   - Click "Change visibility" → "Public"

### 5. Commit and Release

```bash
git add helm/multi-platform-demo/values.yaml \
        helm/multi-platform-demo/Chart.yaml \
        helm/multi-platform-demo/CHANGELOG.md

git commit -m "Use public container registry images"
git push
```

Then merge the PR to trigger automatic Helm chart release!

## For Users Installing

Once published, users can install without building any images:

```bash
helm repo add multi-platform https://xiliath.github.io/multi-platform-demo
helm repo update
helm install my-demo multi-platform/multi-platform-demo
```

Images will be automatically pulled from GitHub Container Registry!

## Updating Images

When you make changes:

```bash
# Build and push new images
./publish-images.sh

# Users pull the latest
helm upgrade my-demo multi-platform/multi-platform-demo
```

## Alternative: Docker Hub

If you prefer Docker Hub instead of GitHub Container Registry:

1. Change `REGISTRY="ghcr.io"` to `REGISTRY="docker.io"`
2. Change `OWNER="xiliath"` to your Docker Hub username
3. Login: `docker login`
4. Run `./publish-images.sh`
