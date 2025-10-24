# Node.js Umbraco Heartcore Client

A lightweight client for fetching content from Umbraco Heartcore Content Delivery API.

## Installation

The client uses only Node.js built-in modules (https), so no additional dependencies are required.

## Usage

```javascript
const UmbracoClient = require('./umbraco-client');

// Initialize the client
const client = new UmbracoClient({
  projectAlias: 'your-project-alias',
  apiKey: 'your-api-key',
  apiUrl: 'https://cdn.umbraco.io', // Optional
  enabled: true, // Optional, default: true
  cacheTtl: 300, // Optional, cache TTL in seconds, default: 300
  fallbackEnabled: true // Optional, default: true
});

// Or use environment variables (recommended)
// UMBRACO_PROJECT_ALIAS, UMBRACO_API_KEY, etc.
const client = new UmbracoClient();

// Fetch home page content
const homePage = await client.fetchHomePage();
console.log(homePage.heading); // "Hello World!"

// Fetch specific content type
const content = await client.fetchContent('homePage');

// Fetch platform configurations
const platforms = await client.fetchPlatformConfigs();

// Get default fallback content (static)
const defaultContent = UmbracoClient.getDefaultHomePageContent();

// Clear cache manually
client.clearCache();
```

## Features

- Built-in caching with configurable TTL
- Automatic fallback to cached content on API errors
- Environment variable configuration
- No external dependencies
- TypeScript-ready

## Error Handling

```javascript
try {
  const content = await client.fetchHomePage();
} catch (error) {
  // API error - use fallback content
  const fallback = UmbracoClient.getDefaultHomePageContent();
  console.error('Using fallback content:', error.message);
}
```

## Environment Variables

- `UMBRACO_PROJECT_ALIAS` - Your Heartcore project alias
- `UMBRACO_API_KEY` - Content Delivery API key
- `UMBRACO_API_URL` - API base URL (default: https://cdn.umbraco.io)
- `UMBRACO_ENABLED` - Enable/disable client (default: true)
- `UMBRACO_CACHE_TTL` - Cache TTL in seconds (default: 300)
- `UMBRACO_FALLBACK_ENABLED` - Enable fallback to cache (default: true)
