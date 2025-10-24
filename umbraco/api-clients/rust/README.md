# Rust Umbraco Heartcore Client

A lightweight async client for fetching content from Umbraco Heartcore Content Delivery API.

## Dependencies

Add to your `Cargo.toml`:

```toml
[dependencies]
reqwest = { version = "0.11", features = ["json"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tokio = { version = "1", features = ["full"] }
```

## Usage

```rust
use umbraco_client::{UmbracoClient, UmbracoConfig};
use std::collections::HashMap;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize the client
    let config = UmbracoConfig {
        project_alias: Some("your-project-alias".to_string()),
        api_key: Some("your-api-key".to_string()),
        api_url: Some("https://cdn.umbraco.io".to_string()), // Optional
        enabled: Some(true), // Optional, default: true
        cache_ttl: Some(300), // Optional, cache TTL in seconds, default: 300
        fallback_enabled: Some(true), // Optional, default: true
    };

    let client = UmbracoClient::new(Some(config));

    // Or use environment variables (recommended)
    // UMBRACO_PROJECT_ALIAS, UMBRACO_API_KEY, etc.
    let client = UmbracoClient::new(None);

    // Fetch home page content
    let home_page = client.fetch_home_page().await?;
    println!("{}", home_page["heading"]); // "Hello World!"

    // Fetch specific content type
    let content = client.fetch_content("homePage", None).await?;

    // Fetch platform configurations
    let platforms = client.fetch_platform_configs().await?;

    // Get default fallback content (static)
    let default_content = UmbracoClient::get_default_home_page_content();

    // Clear cache manually
    client.clear_cache();

    Ok(())
}
```

## Features

- Built-in caching with configurable TTL
- Automatic fallback to cached content on API errors
- Environment variable configuration
- Async/await support with tokio
- Thread-safe cache with Arc<Mutex>

## Error Handling

```rust
match client.fetch_home_page().await {
    Ok(content) => {
        // Use content
    }
    Err(err) => {
        // API error - use fallback content
        let fallback = UmbracoClient::get_default_home_page_content();
        eprintln!("Using fallback content: {}", err);
    }
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

- Rust 1.60+
- Dependencies: reqwest, serde, serde_json, tokio
