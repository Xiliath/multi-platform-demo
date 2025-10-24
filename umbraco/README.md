# Umbraco Heartcore Setup

This directory contains the Umbraco Heartcore headless CMS configuration for the multi-platform demo project.

## Overview

Umbraco Heartcore is used to manage content for all platform home pages, providing a centralized content management system that serves content via REST API to all 6 language implementations (C#/.NET, Node.js, Python, Java, Go, Rust).

## Prerequisites

1. **Umbraco Heartcore Account**: Sign up at [umbraco.com/heartcore](https://umbraco.com/products/umbraco-heartcore/)
2. **API Credentials**: After creating your Heartcore project, you'll need:
   - Project Alias (your-project-name)
   - API Key (Content Delivery API)

## Directory Structure

```
umbraco/
├── content-types/          # Document type definitions
│   ├── homePage.json       # Home page content type
│   └── platformConfig.json # Platform configuration content type
├── api-clients/            # API client implementations
│   ├── dotnet/            # C# client
│   ├── nodejs/            # Node.js client
│   ├── python/            # Python client
│   ├── java/              # Java client
│   ├── go/                # Go client
│   └── rust/              # Rust client
├── config/                 # Configuration templates
│   └── .env.example       # Environment variables template
└── README.md              # This file
```

## Setup Instructions

### 1. Create Umbraco Heartcore Project

1. Go to [umbraco.com/heartcore](https://umbraco.com/products/umbraco-heartcore/)
2. Create a new Heartcore project
3. Note your project alias (e.g., `multi-platform-demo`)

### 2. Create Content Types

In your Umbraco Heartcore backoffice:

1. Navigate to **Settings** → **Document Types**
2. Create the content types defined in `/umbraco/content-types/`
3. Follow the schema definitions for properties and data types

### 3. Configure Environment Variables

1. Copy the example configuration:
   ```bash
   cp umbraco/config/.env.example .env
   ```

2. Update with your Heartcore credentials:
   ```
   UMBRACO_PROJECT_ALIAS=your-project-alias
   UMBRACO_API_KEY=your-api-key
   UMBRACO_API_URL=https://cdn.umbraco.io
   ```

### 4. Create Content

In your Umbraco Heartcore backoffice:

1. Navigate to **Content**
2. Create a new "Home Page" document
3. Fill in the content fields (heading, description, etc.)
4. Publish the content

### 5. Test API Integration

Each platform includes an API client that fetches content from Umbraco. Test the integration:

```bash
# Start the services
docker-compose up

# Access any platform
curl http://localhost:8080/
```

## Content Delivery API

Umbraco Heartcore provides a REST API for content delivery:

**Endpoint**: `https://cdn.umbraco.io/{project-alias}/content`

**Authentication**: Include API key in headers:
```
Umb-Project-Alias: your-project-alias
Api-Key: your-api-key
```

**Example Response**:
```json
{
  "_links": {...},
  "_embedded": {
    "content": [
      {
        "name": "Home",
        "contentType": "homePage",
        "heading": "Hello World!",
        "description": "Welcome to our multi-platform demo",
        ...
      }
    ]
  }
}
```

## API Clients

Each platform has a dedicated API client in `/umbraco/api-clients/` that:
- Fetches content from Umbraco Heartcore
- Caches content locally for performance
- Handles errors gracefully with fallback content
- Supports hot-reload in development

## Development Workflow

1. **Edit Content**: Make changes in Umbraco Heartcore backoffice
2. **Publish**: Publish content to make it available via API
3. **Auto-Refresh**: Platforms will fetch updated content (with caching)
4. **Preview**: View changes at `http://localhost:8080/`

## Fallback Behavior

If Umbraco API is unavailable:
- Platforms use default static content
- Error is logged but application continues to run
- Content updates when API becomes available

## Security Notes

- **Never commit** `.env` file with real credentials
- Use environment variables for API keys
- Restrict API key permissions to read-only
- Use HTTPS in production
- Consider API rate limiting

## Support

- Umbraco Documentation: [docs.umbraco.com](https://docs.umbraco.com/)
- Heartcore API Docs: [docs.umbraco.com/umbraco-heartcore](https://docs.umbraco.com/umbraco-heartcore/)
- Project Issues: [GitHub Issues](https://github.com/Xiliath/multi-platform-demo/issues)
