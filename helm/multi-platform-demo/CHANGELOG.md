# Changelog

All notable changes to this Helm chart will be documented in this file.

## [1.3.3] - 2025-10-24

### Fixed
- **CRITICAL**: Rust Dockerfile now properly rebuilds with actual source code
- Fixed Cargo incremental compilation caching issue that caused dummy binary to run
- Rust container now runs the actual web server instead of empty main()

## [1.3.2] - 2025-10-24

### Fixed
- Rust index handler now correctly links to `/rust/canvas` instead of `/canvas`

## [1.3.1] - 2025-10-24

### Fixed
- **CRITICAL**: Rust template paths now use absolute paths (`/shared` instead of `../shared`)
- Rust container no longer exits immediately on startup
- Rust platform now works correctly in Kubernetes

## [1.3.0] - 2025-10-24

### Added
- **NEW**: Rust 1.82 platform with Actix-web framework (6th platform!)
- Rust Helm chart with Deployment and Service resources
- Rust routes in nginx ConfigMap (/rust, /rust/canvas)
- Automated GitHub Actions workflow for building and publishing container images
- Workflow automatically extracts version from Chart.yaml for consistent tagging
- Container images published to GitHub Container Registry (ghcr.io)

### Fixed
- **CRITICAL**: Added `ghcr.io/xiliath/` registry prefix to all image repositories
- Images can now be pulled from GitHub Container Registry successfully
- Fixed ImagePullBackOff errors when deploying from Helm repository
- Image deployment now works correctly with public registry
- Workflow path filters now include `helm/**` to trigger builds on appVersion changes

### Changed
- Image repositories now use full path: `ghcr.io/xiliath/multi-platform-*`
- All imagePullPolicy changed from `IfNotPresent` to `Always` for reliable updates
- All platforms updated to support Rust navigation
- Increased total platform count from 5 to 6
- Updated all documentation for 6 platforms

### Removed
- All obsolete build and installation scripts (automated via GitHub Actions)
- Redundant troubleshooting scripts (commands documented in helm/README.md)

## [1.1.1] - 2025-10-23

### Changed
- All service image tags updated from `latest` to `1.1.1` for proper versioning
- All imagePullPolicy changed from `IfNotPresent` to `Always` for reliable updates
- nginx imagePullPolicy changed to `Always` for consistency

### Added
- Automated GitHub Actions workflow for building and publishing container images
- Container images now published to GitHub Container Registry (ghcr.io)
- Images automatically built and tagged with Chart appVersion on push to main
- Workflow automatically extracts version from Chart.yaml for consistent tagging

### Removed
- build-k8s-images.sh: No longer needed with automated publishing
- fix-rust-image.sh: No longer needed with public registry
- install-k8s.sh: Replaced by Helm repository installation
- publish-images.sh: Replaced by automated GitHub Actions workflow
- update-helm-for-public-images.sh: One-time script no longer needed
- update-helm-repo.sh: Replaced by automated GitHub Actions workflow
- fix-gh-pages.sh: One-time fix no longer needed

### Fixed
- Image deployment now works correctly with public registry
- Helm upgrades now properly pull updated images
- Version consistency between Chart.yaml appVersion and image tags

## [1.1.0] - 2025-10-23

### Added
- Rust 1.82 platform with Actix-web framework (port 5005)
- Rust Helm chart with Deployment and Service resources
- Rust routes in nginx ConfigMap (/rust, /rust/canvas)
- Rust service configuration in values.yaml
- Rust keyword in Chart.yaml

### Changed
- Updated all platform implementations to support Rust navigation
- Increased total platform count from 5 to 6
- Updated project documentation to reflect 6 platforms

## [1.0.0] - 2025-10-23

### Added
- Initial release of multi-platform-demo Helm chart
- Support for 5 programming languages: .NET 9.0, Node.js 22, Python 3.13, Java 23, Go 1.23
- Real-time collaborative canvas with WebSocket support
- Nginx reverse proxy with LoadBalancer/NodePort support
- QR code integration for mobile access
- Desktop Kubernetes optimization (values-desktop.yaml)
- Comprehensive documentation and troubleshooting guides
- Automated installation scripts (install-k8s.sh, build-k8s-images.sh)
- Diagnostic and fix utilities

### Features
- Multi-platform Hello World web applications
- Shared HTML templates with unified purple gradient theme
- Platform-specific routing (/nodejs, /python, /java, /go)
- Real-time collaborative drawing canvas
- Live user presence tracking
- Canvas history synchronization (last 1000 actions)
- Mobile-friendly QR code generation
- Resource limits and requests for all services
- Support for Docker Desktop, Minikube, and kind clusters

### Architecture
- 7 microservices: dotnet, nodejs, python, java, go, websocket, nginx
- ClusterIP services for internal communication
- LoadBalancer/NodePort for external access
- ConfigMap-based nginx configuration
- Horizontal scaling ready
