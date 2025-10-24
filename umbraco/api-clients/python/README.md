# Python Umbraco Heartcore Client

A lightweight client for fetching content from Umbraco Heartcore Content Delivery API.

## Installation

The client uses only Python standard library modules (urllib, json, os, time), so no additional dependencies are required.

## Usage

```python
from umbraco_client import UmbracoClient

# Initialize the client
client = UmbracoClient({
    'project_alias': 'your-project-alias',
    'api_key': 'your-api-key',
    'api_url': 'https://cdn.umbraco.io',  # Optional
    'enabled': True,  # Optional, default: True
    'cache_ttl': 300,  # Optional, cache TTL in seconds, default: 300
    'fallback_enabled': True  # Optional, default: True
})

# Or use environment variables (recommended)
# UMBRACO_PROJECT_ALIAS, UMBRACO_API_KEY, etc.
client = UmbracoClient()

# Fetch home page content
home_page = client.fetch_home_page()
print(home_page['heading'])  # "Hello World!"

# Fetch specific content type
content = client.fetch_content('homePage')

# Fetch platform configurations
platforms = client.fetch_platform_configs()

# Get default fallback content (static)
default_content = UmbracoClient.get_default_home_page_content()

# Clear cache manually
client.clear_cache()
```

## Features

- Built-in caching with configurable TTL
- Automatic fallback to cached content on API errors
- Environment variable configuration
- No external dependencies
- Type hints included

## Error Handling

```python
try:
    content = client.fetch_home_page()
except Exception as error:
    # API error - use fallback content
    fallback = UmbracoClient.get_default_home_page_content()
    print(f'Using fallback content: {error}')
```

## Environment Variables

- `UMBRACO_PROJECT_ALIAS` - Your Heartcore project alias
- `UMBRACO_API_KEY` - Content Delivery API key
- `UMBRACO_API_URL` - API base URL (default: https://cdn.umbraco.io)
- `UMBRACO_ENABLED` - Enable/disable client (default: true)
- `UMBRACO_CACHE_TTL` - Cache TTL in seconds (default: 300)
- `UMBRACO_FALLBACK_ENABLED` - Enable fallback to cache (default: true)

## Requirements

- Python 3.6+
- No external dependencies (uses standard library only)
