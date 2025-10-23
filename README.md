# Multi-Platform Hello World Demo

A unique Hello World website implemented in 5 of the most popular programming languages, all serving the same beautiful UI with identical styling. Each platform is accessible via its own route, with .NET serving as the default homepage.

## Features

- **Unified Design**: All platforms serve the exact same UI with consistent styling
- **5 Modern Platforms**: Built with the latest versions of popular programming languages
- **Docker-Powered**: Easy deployment using Docker Compose
- **Nginx Routing**: Intelligent reverse proxy for seamless navigation

## Platforms

| Platform | Language | Framework | Version | Route | Port |
|----------|----------|-----------|---------|-------|------|
| .NET | C# | ASP.NET Core | 9.0 | `/` (default) | 5000 |
| Node.js | JavaScript | Native HTTP | 22.x | `/nodejs` | 5001 |
| Python | Python | Flask | 3.13 | `/python` | 5002 |
| Java | Java | Spring Boot | 23 | `/java` | 5003 |
| Go | Go | Native HTTP | 1.23 | `/go` | 5004 |

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
├── shared/              # Shared resources
│   └── templates/
│       └── index.html   # Unified HTML template
├── nginx/               # Nginx configuration
│   └── nginx.conf
└── docker-compose.yml   # Orchestration file
```

## Quick Start

### Prerequisites

- Docker (20.10+)
- Docker Compose (2.0+)

### Running the Application

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

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.