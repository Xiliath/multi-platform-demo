# Multi-Platform Hello World Demo

A unique Hello World website implemented in 6 of the most popular programming languages, all serving the same beautiful UI with identical styling. Each platform is accessible via its own route, with .NET serving as the default homepage.

## Features

- **Unified Design**: All platforms serve the exact same UI with consistent styling
- **6 Modern Platforms**: Built with the latest versions of popular programming languages
- **Real-time Collaborative Canvas**: Draw together with users from all platforms in real-time!
- **Beta Testing Registration**: Collect user signups with email and platform selection
- **Admin Dashboard**: Real-time view of registrations with export functionality
- **QR Code Access**: Easy mobile registration via scannable QR codes
- **WebSocket Communication**: Live synchronization across all connected users
- **Docker-Powered**: Easy deployment using Docker Compose
- **Nginx Routing**: Intelligent reverse proxy for seamless navigation
- **Hot Reload Development**: Watch mode with automatic file syncing and rebuilds

## Platforms

| Platform | Language | Framework | Version | Route | Port |
|----------|----------|-----------|---------|-------|------|
| .NET | C# | ASP.NET Core | 9.0 | `/` (default) | 5000 |
| Node.js | JavaScript | Native HTTP | 22.x | `/nodejs` | 5001 |
| Python | Python | Flask | 3.13 | `/python` | 5002 |
| Java | Java | Spring Boot | 23 | `/java` | 5003 |
| Go | Go | Native HTTP | 1.23 | `/go` | 5004 |
| Rust | Rust | Actix-web | 1.82 | `/rust` | 5005 |

## Project Structure

```
multi-platform-demo/
├── dotnet/              # C# .NET implementation
│   ├── Program.cs
│   ├── HelloWorld.csproj
│   └── Dockerfile
├── nodejs/              # Node.js implementation
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── python/              # Python Flask implementation
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── java/                # Java Spring Boot implementation
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile
├── go/                  # Go implementation
│   ├── main.go
│   ├── go.mod
│   └── Dockerfile
├── rust/                # Rust implementation
│   ├── src/
│   │   └── main.rs
│   ├── Cargo.toml
│   └── Dockerfile
├── websocket/           # WebSocket server for real-time features
│   ├── server.js        # Canvas & registration sync
│   ├── package.json
│   └── Dockerfile
├── shared/              # Shared resources
│   └── templates/
│       ├── index.html          # Unified HTML template
│       ├── canvas.html         # Collaborative canvas
│       ├── join.html           # QR codes for canvas
│       ├── registration.html   # Beta testing registration form
│       ├── admin.html          # Admin dashboard
│       └── register-qr.html    # QR code for registration
├── nginx/               # Nginx configuration
│   └── nginx.conf
└── docker-compose.yml   # Orchestration file
```

## Quick Start

### Option 1: Kubernetes (Production)

For production deployments, use our official Helm chart:

#### Prerequisites
- Kubernetes cluster (1.24+)
- Helm 3.x
- kubectl configured

#### Installation

**1. Add the Helm repository:**
```bash
helm repo add multi-platform https://xiliath.github.io/multi-platform-demo
helm repo update
```

**2. Install the chart:**

For **cloud Kubernetes** (AWS EKS, Google GKE, Azure AKS):
```bash
helm install my-demo multi-platform/multi-platform-demo
```

For **desktop Kubernetes** (Docker Desktop, Minikube, kind):
```bash
helm install my-demo multi-platform/multi-platform-demo \
  --set nginx.service.type=NodePort
```

**3. Access the application:**

Get service details:
```bash
kubectl get service my-demo-nginx
```

For NodePort access:
```bash
kubectl port-forward service/my-demo-nginx 8080:80 8081:8081
```
Then open: http://localhost:8080

See the [Helm Chart Documentation](helm/README.md) for detailed configuration options.

### Option 2: Docker Compose (Development)

#### Prerequisites

- Docker (20.10+)
- Docker Compose (2.0+)

#### Running the Application

1. Clone the repository:
```bash
git clone <repository-url>
cd multi-platform-demo
```

2. Build and start all services:
```bash
docker-compose up --build
```

3. Open your browser and navigate to:
   - http://localhost:8080 - Default (.NET)
   - http://localhost:8080/nodejs - Node.js version
   - http://localhost:8080/python - Python version
   - http://localhost:8080/java - Java version
   - http://localhost:8080/go - Go version
   - http://localhost:8080/rust - Rust version

   **Collaborative Canvas (accessible from ALL platforms):**
   - http://localhost:8080/canvas - Canvas via .NET
   - http://localhost:8080/nodejs/canvas - Canvas via Node.js
   - http://localhost:8080/python/canvas - Canvas via Python
   - http://localhost:8080/java/canvas - Canvas via Java
   - http://localhost:8080/go/canvas - Canvas via Go
   - http://localhost:8080/rust/canvas - Canvas via Rust

   All canvas routes share the SAME drawing surface in real-time!

   **Beta Testing Registration:**
   - http://localhost:8080/registration - User registration form
   - http://localhost:8080/admin - Admin dashboard with registration list
   - http://localhost:8080/register-qr - QR code for mobile registration

### Development with Watch Mode (Hot Reload)

For a smooth development experience with automatic file syncing and hot-reloading:

```bash
docker-compose up --watch
```

This enables automatic updates when you edit code:

**Instant Sync (No Rebuild):**
- **.NET**: Changes to `.cs` files sync automatically
- **Node.js**: Changes to `.js` files sync and server restarts
- **Python**: Changes to `.py` files sync and Flask reloads
- **WebSocket**: Changes to `.js` files sync and server restarts
- **Shared Templates**: Changes to HTML templates sync to all services instantly!

**Automatic Rebuild:**
- **.NET**: Rebuilds when `HelloWorld.csproj` changes
- **Node.js**: Rebuilds when `package.json` changes
- **Python**: Rebuilds when `requirements.txt` changes
- **Java**: Rebuilds when source files or `pom.xml` change
- **Go**: Rebuilds when `.go` files change

**Example workflow:**
1. Run `docker-compose up --watch`
2. Edit `shared/templates/canvas.html` to change the UI
3. Refresh your browser - changes appear instantly!
4. Edit `nodejs/server.js` to modify functionality
5. Server automatically restarts with your changes

This creates a true hot-reload development experience across all 6 platforms!

### Stopping the Application

```bash
docker-compose down
```

## Running Individual Platforms

Each platform can also be run independently without Docker:

### .NET
```bash
cd dotnet
dotnet run
```

### Node.js
```bash
cd nodejs
npm start
```

### Python
```bash
cd python
pip install -r requirements.txt
python app.py
```

### Java
```bash
cd java
mvn spring-boot:run
```

### Go
```bash
cd go
go run main.go
```

### Rust
```bash
cd rust
cargo run
```

## Collaborative Canvas Feature

The demo includes a **real-time collaborative drawing canvas** that showcases advanced multi-platform capabilities:

### Features
- **Real-time Drawing**: See strokes from all users instantly
- **Multi-Platform Support**: Users from any platform can draw together
- **Live User List**: See who's online and which platform they're using
- **Color Palette**: 10 vibrant colors to choose from
- **Brush Sizes**: 4 different brush sizes (small, medium, large, extra-large)
- **Canvas Actions**: Clear canvas, download artwork as PNG
- **Touch Support**: Works on mobile devices and tablets
- **Auto-Reconnect**: Automatically reconnects if connection is lost

### Technical Implementation
- **WebSocket Server**: Node.js with `ws` library for real-time communication
- **Canvas History**: Last 1000 drawing actions stored in memory
- **Synchronized State**: All connected clients receive the same canvas state
- **Platform Detection**: Shows which platform each user is connecting from

### How to Experience Cross-Platform Collaboration

1. Open **http://localhost:8080/nodejs/canvas** in one browser tab (Node.js)
2. Open **http://localhost:8080/python/canvas** in another tab (Python)
3. Open **http://localhost:8080/java/canvas** in a third tab (Java)
4. Draw in any tab and watch it appear instantly in ALL tabs!
5. The user list shows which platform each person is using

All platforms connect to the same WebSocket server and share the same canvas state.

### QR Codes for Demo Attendees

Perfect for live demos and presentations! Allow attendees to join from their phones.

**Setup:**
1. Find your computer's local IP address:
   - **Windows**: Run `ipconfig` in Command Prompt (look for IPv4 Address)
   - **Mac/Linux**: Run `ifconfig` or `ip addr` (look for inet address)

2. On your computer, visit: `http://YOUR-IP-ADDRESS:8080/join`
   - Example: `http://192.168.1.100:8080/join`

3. **Display the QR codes** on your screen or projector

4. **Attendees scan** any QR code with their phone's camera

5. **Everyone draws together** in real-time on the same canvas!

**Features:**
- 6 different QR codes (one for each platform)
- All QR codes lead to the same shared canvas
- Automatically uses your computer's IP address
- Shows helpful setup instructions if accessed via localhost
- Works on phones, tablets, and any device with a camera

## Beta Testing Registration System

The application includes a complete registration system for collecting beta tester signups with real-time data synchronization across all platforms.

### Features

- **User Registration**: Simple form collecting email and platform (Android/iOS)
- **Admin Dashboard**: Real-time view of all registrations with statistics
- **QR Code Access**: Scannable QR code for easy mobile registration
- **Real-time Updates**: Admin dashboard updates instantly when users register
- **Data Export**: Export registrations to CSV for further processing
- **Duplicate Prevention**: Validates and prevents duplicate email addresses
- **Cross-Platform**: Works with all 6 backend implementations
- **In-Memory Storage**: Registrations stored in WebSocket server memory

### How to Use

#### For Users (Registration)

1. **Desktop Access**: Visit `http://localhost:8080/registration`
2. **Mobile Access**:
   - Visit `http://YOUR-IP-ADDRESS:8080/register-qr` to display QR code
   - Scan the QR code with a phone camera
   - Fill out the registration form
3. **Enter Email**: Provide a valid email address
4. **Select Platform**: Choose Android or iOS
5. **Submit**: Registration is saved instantly

#### For Administrators

1. **Access Dashboard**: Visit `http://localhost:8080/admin`
2. **View Statistics**: See total signups and breakdown by platform
3. **Filter Data**: Filter registrations by platform (All/Android/iOS)
4. **Export Data**: Click "Export CSV" to download registration list
5. **Live Updates**: Dashboard automatically updates when new users register

### QR Code Setup for Mobile Registration

Perfect for events, demos, and presentations:

**Setup:**
1. Find your computer's local IP address:
   - **Windows**: Run `ipconfig` in Command Prompt (look for IPv4 Address)
   - **Mac/Linux**: Run `ifconfig` or `ip addr` (look for inet address)

2. Visit `http://YOUR-IP-ADDRESS:8080/register-qr` on your computer
   - Example: `http://192.168.1.100:8080/register-qr`

3. **Display the QR code** on your screen, projector, or print it

4. **Attendees scan** the QR code with their phone's camera

5. **They register** directly from their phones!

**Features:**
- Large, easily scannable QR code
- Copy link button for sharing
- Automatic IP detection
- Works with any QR code reader or phone camera
- Helpful setup instructions for localhost environments

### Technical Implementation

**Data Storage:**
- Registrations stored in WebSocket server memory
- Shared across all platforms in real-time
- Persists as long as the WebSocket server is running
- No database required

**Routes Available:**
- `/registration` - Registration form (all platforms)
- `/admin` - Admin dashboard (all platforms)
- `/register-qr` - QR code page (static, no platform rendering)

**Platform-Specific Routes:**
- `/nodejs/registration`, `/python/registration`, etc.
- `/nodejs/admin`, `/python/admin`, etc.
- Each backend serves the same templates with their platform name

**WebSocket Messages:**
- `register` - Submit new registration
- `get_registrations` - Request current registration list
- `new_registration` - Broadcast when user registers
- `registrations_list` - Response with all registrations

### Example Use Cases

**Beta Program Launch:**
1. Share the registration QR code on social media
2. Monitor signups in real-time via admin dashboard
3. Export data to CSV for email marketing

**Event Registration:**
1. Display QR code at your booth or on slides
2. Attendees register on their phones
3. Track registrations live during the event
4. Export data immediately after event

**Product Demo:**
1. Show the registration page during presentation
2. Encourage audience to sign up
3. Display real-time registration count on admin dashboard
4. Download email list for follow-up

## Technical Details

### Unified UI Design

All platforms use the same HTML template located in `shared/templates/index.html` with:
- Modern gradient background
- Responsive design
- Platform-specific badge highlighting
- Dynamic version information
- Real-time timestamp
- Navigation between all platforms

### Routing Architecture

The application uses Nginx as a reverse proxy:
- Routes requests to appropriate backend services
- Handles load balancing
- Manages SSL/TLS (when configured)
- Provides a single entry point

### Platform Highlights

**C# (.NET 9.0)**
- Minimal API approach
- Fast startup time
- Native async/await support

**Node.js (v22)**
- Native HTTP module
- Non-blocking I/O
- JavaScript runtime

**Python (3.13 + Flask)**
- Clean and simple syntax
- Flask micro-framework
- Jinja2 templating support

**Java (23 + Spring Boot 3.4)**
- Enterprise-grade framework
- Dependency injection
- Production-ready features

**Go (1.23)**
- Compiled binary
- Excellent performance
- Built-in concurrency

**Rust (1.82 + Actix-web)**
- Memory safety without garbage collection
- High performance
- Modern async runtime

## Development

### Adding a New Platform

1. Create a new directory for your platform
2. Implement a web server that serves the shared HTML template
3. Replace the template variables with platform-specific values
4. Create a Dockerfile
5. Add the service to `docker-compose.yml`
6. Update the Nginx configuration

### Customizing the UI

Edit `shared/templates/index.html` to modify the design. All platforms will automatically use the updated template.

## Deployment Options

### Kubernetes with Helm (Recommended for Production)

The application includes production-ready Helm charts for Kubernetes deployment:

- **Official Helm Repository**: https://xiliath.github.io/multi-platform-demo
- **Chart Documentation**: [helm/README.md](helm/README.md)
- **Quick Install**: `helm install my-demo multi-platform/multi-platform-demo`

Features:
- Horizontal Pod Autoscaling ready
- Resource limits and requests configured
- Nginx LoadBalancer/NodePort support
- ConfigMap-based configuration
- Support for cloud and desktop Kubernetes
- Automated installation scripts included

### Docker Compose (Development)

Perfect for local development with hot-reload support:

```bash
docker-compose up --watch
```

Features:
- Hot-reload for code changes
- Instant template synchronization
- Automatic rebuilds when dependencies change
- All services running locally

### Manual Installation

Each platform can run independently. See "Running Individual Platforms" section above.

## Documentation

- [Helm Chart Documentation](helm/README.md) - Kubernetes deployment guide
- [Troubleshooting Guide](helm/README.md#troubleshooting) - Common issues and solutions
- [Changelog](helm/multi-platform-demo/CHANGELOG.md) - Version history

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.