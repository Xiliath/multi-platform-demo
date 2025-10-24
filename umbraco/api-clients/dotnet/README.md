# .NET Umbraco Heartcore Client

A lightweight client for fetching content from Umbraco Heartcore Content Delivery API.

## Installation

The client uses .NET built-in libraries (System.Net.Http, System.Text.Json), so no additional NuGet packages are required.

## Usage

```csharp
using MultiPlatformDemo.Umbraco;

// Initialize the client
var client = new UmbracoClient(new UmbracoConfig
{
    ProjectAlias = "your-project-alias",
    ApiKey = "your-api-key",
    ApiUrl = "https://cdn.umbraco.io", // Optional
    Enabled = true, // Optional, default: true
    CacheTtl = 300, // Optional, cache TTL in seconds, default: 300
    FallbackEnabled = true // Optional, default: true
});

// Or use environment variables (recommended)
// UMBRACO_PROJECT_ALIAS, UMBRACO_API_KEY, etc.
var client = new UmbracoClient();

// Fetch home page content
var homePage = await client.FetchHomePageAsync();
var heading = homePage.GetProperty("heading").GetString();
Console.WriteLine(heading); // "Hello World!"

// Fetch specific content type
var content = await client.FetchContentAsync("homePage");

// Fetch platform configurations
var platforms = await client.FetchPlatformConfigsAsync();

// Get default fallback content (static)
var defaultContent = UmbracoClient.GetDefaultHomePageContent();

// Clear cache manually
client.ClearCache();
```

## Features

- Built-in caching with configurable TTL
- Automatic fallback to cached content on API errors
- Environment variable configuration
- No external dependencies (uses System.Net.Http and System.Text.Json)
- Async/await support

## Error Handling

```csharp
try
{
    var content = await client.FetchHomePageAsync();
}
catch (Exception error)
{
    // API error - use fallback content
    var fallback = UmbracoClient.GetDefaultHomePageContent();
    Console.Error.WriteLine($"Using fallback content: {error.Message}");
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

- .NET 6.0+
- No external dependencies (uses built-in libraries)
