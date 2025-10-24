# Java Umbraco Heartcore Client

A lightweight client for fetching content from Umbraco Heartcore Content Delivery API.

## Dependencies

Add Jackson for JSON parsing to your `pom.xml`:

```xml
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.15.0</version>
</dependency>
```

The client also uses Java 11+ HttpClient (java.net.http).

## Usage

```java
import com.demo.UmbracoClient;
import com.demo.UmbracoClient.UmbracoConfig;
import com.fasterxml.jackson.databind.JsonNode;

// Initialize the client
UmbracoConfig config = new UmbracoConfig();
config.setProjectAlias("your-project-alias");
config.setApiKey("your-api-key");
config.setApiUrl("https://cdn.umbraco.io"); // Optional
config.setEnabled(true); // Optional, default: true
config.setCacheTtl(300); // Optional, cache TTL in seconds, default: 300
config.setFallbackEnabled(true); // Optional, default: true

UmbracoClient client = new UmbracoClient(config);

// Or use environment variables (recommended)
// UMBRACO_PROJECT_ALIAS, UMBRACO_API_KEY, etc.
UmbracoClient client = new UmbracoClient();

// Fetch home page content
JsonNode homePage = client.fetchHomePage();
String heading = homePage.get("heading").asText();
System.out.println(heading); // "Hello World!"

// Fetch specific content type
JsonNode content = client.fetchContent("homePage", new HashMap<>());

// Fetch platform configurations
List<JsonNode> platforms = client.fetchPlatformConfigs();

// Get default fallback content (static)
Map<String, Object> defaultContent = UmbracoClient.getDefaultHomePageContent();

// Clear cache manually
client.clearCache();
```

## Features

- Built-in caching with configurable TTL
- Automatic fallback to cached content on API errors
- Environment variable configuration
- Uses Java 11+ HttpClient
- Thread-safe

## Error Handling

```java
try {
    JsonNode content = client.fetchHomePage();
} catch (Exception error) {
    // API error - use fallback content
    Map<String, Object> fallback = UmbracoClient.getDefaultHomePageContent();
    System.err.println("Using fallback content: " + error.getMessage());
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

- Java 11+
- Jackson Databind library
