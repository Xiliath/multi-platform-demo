# Changelog

All notable changes to this Helm chart will be documented in this file.

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
