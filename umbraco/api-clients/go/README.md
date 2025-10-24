# Go Umbraco Heartcore Client

A lightweight client for fetching content from Umbraco Heartcore Content Delivery API.

## Installation

The client uses only Go standard library packages (net/http, encoding/json, etc.), so no additional dependencies are required.

## Usage

```go
package main

import (
    "fmt"
    "log"
    "your-module/umbraco"
)

func main() {
    // Initialize the client
    enabled := true
    cacheTTL := 300
    fallbackEnabled := true

    client := umbraco.NewClient(&umbraco.Config{
        ProjectAlias:    "your-project-alias",
        APIKey:          "your-api-key",
        APIURL:          "https://cdn.umbraco.io", // Optional
        Enabled:         &enabled,                  // Optional, default: true
        CacheTTL:        &cacheTTL,                 // Optional, cache TTL in seconds, default: 300
        FallbackEnabled: &fallbackEnabled,          // Optional, default: true
    })

    // Or use environment variables (recommended)
    // UMBRACO_PROJECT_ALIAS, UMBRACO_API_KEY, etc.
    client := umbraco.NewClient(nil)

    // Fetch home page content
    homePage, err := client.FetchHomePage()
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println(homePage["heading"]) // "Hello World!"

    // Fetch specific content type
    content, err := client.FetchContent("homePage", nil)

    // Fetch platform configurations
    platforms, err := client.FetchPlatformConfigs()

    // Get default fallback content (static)
    defaultContent := umbraco.GetDefaultHomePageContent()

    // Clear cache manually
    client.ClearCache()
}
```

## Features

- Built-in caching with configurable TTL
- Automatic fallback to cached content on API errors
- Environment variable configuration
- Thread-safe cache with mutex protection
- No external dependencies

## Error Handling

```go
content, err := client.FetchHomePage()
if err != nil {
    // API error - use fallback content
    fallback := umbraco.GetDefaultHomePageContent()
    log.Printf("Using fallback content: %v", err)
}
```

## Environment Variables

- `UMBRACO_PROJECT_ALIAS` - Your Heartcore project alias
- `UMBRACO_API_KEY` - Content Delivery API key
- `UMBRACO_API_URL` - API base URL (default: https://cdn.umbraco.io)
- `UMBRACO_ENABLED` - Enable/disable client (default: true)
- `UMBRACO_CACHE_TTL` - Cache TTL in seconds (default: 300)
- `UMBRACO_FALLBACK_ENABLED` - Enable fallback to cache (default: true)

## Requirements

- Go 1.16+
- No external dependencies (uses standard library only)
