"""
Umbraco Heartcore API Client for Python

This client fetches content from Umbraco Heartcore Content Delivery API
with built-in caching and fallback support.
"""

import os
import json
import time
from typing import Dict, List, Optional, Any
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError
from urllib.parse import urlencode


class UmbracoClient:
    """Client for interacting with Umbraco Heartcore Content Delivery API"""

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        config = config or {}

        self.project_alias = config.get('project_alias') or os.getenv('UMBRACO_PROJECT_ALIAS')
        self.api_key = config.get('api_key') or os.getenv('UMBRACO_API_KEY')
        self.api_url = config.get('api_url') or os.getenv('UMBRACO_API_URL') or 'https://cdn.umbraco.io'

        enabled_env = os.getenv('UMBRACO_ENABLED', 'true').lower()
        self.enabled = config.get('enabled', enabled_env != 'false')

        cache_ttl_env = os.getenv('UMBRACO_CACHE_TTL', '300')
        self.cache_ttl = int(config.get('cache_ttl', cache_ttl_env))

        fallback_env = os.getenv('UMBRACO_FALLBACK_ENABLED', 'true').lower()
        self.fallback_enabled = config.get('fallback_enabled', fallback_env != 'false')

        # Simple in-memory cache
        self._cache: Dict[str, Dict[str, Any]] = {}

    def fetch_content(self, content_type: str, options: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """
        Fetch content from Umbraco Heartcore API

        Args:
            content_type: The content type alias (e.g., 'homePage')
            options: Additional query parameters

        Returns:
            The content object

        Raises:
            Exception: If API request fails and no cache is available
        """
        if not self.enabled:
            raise Exception('Umbraco client is disabled')

        if not self.project_alias or not self.api_key:
            raise Exception('Umbraco project alias and API key are required')

        options = options or {}
        cache_key = f"{content_type}:{json.dumps(options, sort_keys=True)}"

        # Check cache
        cached = self._cache.get(cache_key)
        if cached and time.time() - cached['timestamp'] < self.cache_ttl:
            return cached['data']

        try:
            url = f"{self.api_url}/{self.project_alias}/content/type/{content_type}"
            data = self._make_request(url, options)

            # Extract first content item
            content = data.get('_embedded', {}).get('content', [None])[0]

            if not content:
                raise Exception(f'No content found for type: {content_type}')

            # Cache the result
            self._cache[cache_key] = {
                'data': content,
                'timestamp': time.time()
            }

            return content

        except Exception as error:
            print(f'Umbraco API error: {str(error)}')

            # Return cached data if available (even if expired)
            if cached:
                print('Using expired cache due to API error')
                return cached['data']

            raise

    def fetch_home_page(self) -> Dict[str, Any]:
        """Fetch the home page content"""
        return self.fetch_content('homePage')

    def fetch_platform_configs(self) -> List[Dict[str, Any]]:
        """Fetch platform configurations"""
        url = f"{self.api_url}/{self.project_alias}/content/type/platformConfig"
        data = self._make_request(url, {'sort': 'sortOrder:asc'})
        return data.get('_embedded', {}).get('content', [])

    def clear_cache(self):
        """Clear the cache"""
        self._cache.clear()

    def _make_request(self, url: str, query_params: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """
        Make an HTTP request to the Umbraco API

        Args:
            url: The API endpoint URL
            query_params: Query parameters to include

        Returns:
            Parsed JSON response
        """
        query_params = query_params or {}

        # Build query string
        if query_params:
            query_string = urlencode(query_params)
            full_url = f"{url}?{query_string}"
        else:
            full_url = url

        # Create request with headers
        req = Request(full_url)
        req.add_header('Accept', 'application/json')
        req.add_header('Umb-Project-Alias', self.project_alias)
        req.add_header('Api-Key', self.api_key)

        try:
            with urlopen(req, timeout=5) as response:
                data = response.read().decode('utf-8')
                return json.loads(data)
        except HTTPError as error:
            raise Exception(f'HTTP {error.code}: {error.read().decode("utf-8")}')
        except URLError as error:
            raise Exception(f'URL error: {str(error.reason)}')
        except json.JSONDecodeError as error:
            raise Exception(f'Failed to parse JSON response: {str(error)}')

    @staticmethod
    def get_default_home_page_content() -> Dict[str, Any]:
        """Get fallback content for home page"""
        return {
            'heading': 'Hello World!',
            'description': 'Welcome to our multi-platform demo showcasing C# (.NET), Node.js, Python, Java, Go, and Rust implementations.',
            'canvasSectionTitle': 'Collaborative Canvas',
            'canvasDescription': 'Try our real-time collaborative drawing canvas! Draw together with others across different platforms.',
            'launchCanvasButtonText': 'Launch Canvas',
            'showQrCodeSection': True,
            'qrCodeButtonText': 'Show QR Codes',
            'platformLinksTitle': 'Try Other Platforms',
            'showPlatformNavigation': True,
            'showServerInfo': True,
            'backgroundGradientStart': '#667eea',
            'backgroundGradientEnd': '#764ba2',
            'seoTitle': 'Multi-Platform Demo',
            'seoDescription': 'A demonstration of the same application built with multiple platforms.',
            'seoKeywords': 'multi-platform, demo'
        }
