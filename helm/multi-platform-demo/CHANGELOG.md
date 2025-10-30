# Changelog

All notable changes to this Helm chart will be documented in this file.

## [1.6.0] - 2025-10-28

### Security
- **NEW**: Admin routes now protected with secret header authentication
- Admin panel requires `X-Admin-Secret: my-demo-secret-2025` header to access
- Unauthorized admin access redirects to `/blocked` page
- All 6 platform-specific admin routes secured: `/admin`, `/nodejs/admin`, `/python/admin`, `/java/admin`, `/go/admin`, `/rust/admin`

### Changed
- Signup link and QR code now correctly point to `/registration` instead of `/register-qr`
- Refactored nginx configuration using `map` directive for DRY admin authentication
- Secret validation now defined once at http level instead of repeated in each location

### Removed
- Removed unused `/register-qr` routes from all 6 backend platforms
- Removed `/register-qr` location blocks from nginx configuration
- Deleted unused `register-qr.html` template file

### Technical Details
- Admin authentication uses nginx `map $http_x_admin_secret $admin_allowed` for single source of truth
- Reduced code duplication in nginx config (42 lines removed)
- Cleaner, more maintainable security configuration
- Docker image tags remain at 1.5.0 (will be updated to 1.6.0 automatically when merged to main)

### How to Access Admin Panel
Users must install a browser header modification extension:
- Chrome/Edge: ModHeader or Requestly
- Firefox: Modify Header Value
- Add header: `X-Admin-Secret: my-demo-secret-2025`

## [1.5.0] - 2025-10-28

### Added
- **NEW**: Registration QR code now displayed on homescreen alongside canvas QR
- **NEW**: IP-based access control for homescreen routes (localhost and internal networks only)
- **NEW**: Fun "blocked" warning page for unauthorized access attempts
- Visible admin link on homescreen (honeypot for demo purposes)
- `/blocked` route added to all 6 backend platforms
- Nginx IP whitelist configuration with automatic redirect to blocked page

### Changed
- QR code URL generation now uses `window.location.protocol` and `window.location.host` for dynamic port handling
- Homescreen layout redesigned with side-by-side QR code sections (canvas and registration)
- Registration section styled with green gradient for visual distinction
- All Docker image tags updated to 1.5.0 (dotnet, nodejs, python, java, go, rust, websocket)

### Security
- Homescreen routes now restricted to:
  - Localhost: 127.0.0.1
  - Docker networks: 172.16.0.0/12
  - Private networks: 10.0.0.0/8, 192.168.0.0/16
- Unauthorized access redirects to humorous blocked page (demo honeypot)

### Technical Details
- IP restrictions implemented in nginx configuration using allow/deny directives
- Error page 403 redirects to @blocked location handler
- Responsive homescreen design with flex layout for QR code sections
- Admin panel link intentionally visible for demonstration purposes

## [1.4.1] - 2025-10-28

### Fixed
- **CRITICAL**: Updated Rust from 1.82 to 1.83 to resolve dependency compatibility issues
- Fixed image tags in values.yaml to correctly reference 1.4.0 images
- Resolved ICU library dependencies requiring Rust 1.83+

### Changed
- All Docker image tags updated to 1.4.1 (dotnet, nodejs, python, java, go, rust, websocket)
- Updated Rust platform display from "Rust 1.82" to "Rust 1.83" throughout codebase

### Technical Details
This is a patch release to fix issues discovered after 1.4.0 was published:
- Rust Dockerfile now uses rust:1.83 base image
- helm upgrade will now correctly pull 1.4.1 images with all registration features and fixes
- Rust build succeeds without dependency version conflicts

## [1.4.0] - 2025-10-28

### Added
- **NEW**: Beta Testing Registration System with real-time data synchronization
- Registration form for collecting email and platform (Android/iOS) signups
- Admin dashboard with live registration statistics and filtering
- QR code page for easy mobile registration access
- Real-time WebSocket updates when users register
- CSV export functionality in admin dashboard
- Duplicate email validation
- Three new templates: `registration.html`, `admin.html`, `register-qr.html`
- New routes in all 6 backend platforms: `/registration`, `/admin`, `/register-qr`
- WebSocket message handlers for registration system
- In-memory registration storage in WebSocket server
- Platform-specific registration routes (e.g., `/nodejs/registration`)

### Changed
- Updated nginx ConfigMap with new registration routes for all platforms
- Enhanced WebSocket server to handle registration messages
- Updated all 6 backend implementations (.NET, Node.js, Python, Java, Go, Rust)
- Expanded project documentation with registration system guide
- Updated README with comprehensive registration feature documentation

### Technical Details
- Registrations stored in WebSocket server memory (no database required)
- Cross-platform data sharing via WebSocket
- Real-time admin dashboard updates
- Email format validation and duplicate prevention
- Responsive UI matching existing design language

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
- **NEW**: Rust 1.83 platform with Actix-web framework (6th platform!)
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
- Rust 1.83 platform with Actix-web framework (port 5005)
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
