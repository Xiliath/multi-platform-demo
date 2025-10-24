/**
 * Umbraco Heartcore API Client for Node.js
 *
 * This client fetches content from Umbraco Heartcore Content Delivery API
 * with built-in caching and fallback support.
 */

const https = require('https');

class UmbracoClient {
  constructor(config = {}) {
    this.projectAlias = config.projectAlias || process.env.UMBRACO_PROJECT_ALIAS;
    this.apiKey = config.apiKey || process.env.UMBRACO_API_KEY;
    this.apiUrl = config.apiUrl || process.env.UMBRACO_API_URL || 'https://cdn.umbraco.io';
    this.enabled = config.enabled !== false && process.env.UMBRACO_ENABLED !== 'false';
    this.cacheTtl = parseInt(config.cacheTtl || process.env.UMBRACO_CACHE_TTL || '300') * 1000; // Convert to ms
    this.fallbackEnabled = config.fallbackEnabled !== false && process.env.UMBRACO_FALLBACK_ENABLED !== 'false';

    // Simple in-memory cache
    this.cache = new Map();
  }

  /**
   * Fetch content from Umbraco Heartcore API
   * @param {string} contentType - The content type alias (e.g., 'homePage')
   * @param {object} options - Additional query options
   * @returns {Promise<object>} The content object
   */
  async fetchContent(contentType, options = {}) {
    if (!this.enabled) {
      throw new Error('Umbraco client is disabled');
    }

    if (!this.projectAlias || !this.apiKey) {
      throw new Error('Umbraco project alias and API key are required');
    }

    const cacheKey = `${contentType}:${JSON.stringify(options)}`;

    // Check cache
    const cached = this.cache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < this.cacheTtl) {
      return cached.data;
    }

    try {
      const url = `${this.apiUrl}/${this.projectAlias}/content/type/${contentType}`;
      const data = await this._makeRequest(url, options);

      // Extract first content item
      const content = data._embedded?.content?.[0] || null;

      if (!content) {
        throw new Error(`No content found for type: ${contentType}`);
      }

      // Cache the result
      this.cache.set(cacheKey, {
        data: content,
        timestamp: Date.now()
      });

      return content;
    } catch (error) {
      console.error('Umbraco API error:', error.message);

      // Return cached data if available (even if expired)
      if (cached) {
        console.warn('Using expired cache due to API error');
        return cached.data;
      }

      throw error;
    }
  }

  /**
   * Fetch the home page content
   * @returns {Promise<object>} The home page content
   */
  async fetchHomePage() {
    return this.fetchContent('homePage');
  }

  /**
   * Fetch platform configurations
   * @returns {Promise<Array>} Array of platform configurations
   */
  async fetchPlatformConfigs() {
    const data = await this._makeRequest(
      `${this.apiUrl}/${this.projectAlias}/content/type/platformConfig`,
      { sort: 'sortOrder:asc' }
    );

    return data._embedded?.content || [];
  }

  /**
   * Clear the cache
   */
  clearCache() {
    this.cache.clear();
  }

  /**
   * Make an HTTP request to the Umbraco API
   * @private
   */
  _makeRequest(url, queryParams = {}) {
    return new Promise((resolve, reject) => {
      // Build query string
      const queryString = Object.keys(queryParams)
        .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(queryParams[key])}`)
        .join('&');

      const fullUrl = queryString ? `${url}?${queryString}` : url;
      const urlObj = new URL(fullUrl);

      const options = {
        hostname: urlObj.hostname,
        path: urlObj.pathname + urlObj.search,
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'Umb-Project-Alias': this.projectAlias,
          'Api-Key': this.apiKey
        }
      };

      const req = https.request(options, (res) => {
        let data = '';

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => {
          if (res.statusCode >= 200 && res.statusCode < 300) {
            try {
              resolve(JSON.parse(data));
            } catch (error) {
              reject(new Error(`Failed to parse JSON response: ${error.message}`));
            }
          } else {
            reject(new Error(`HTTP ${res.statusCode}: ${data}`));
          }
        });
      });

      req.on('error', (error) => {
        reject(error);
      });

      req.setTimeout(5000, () => {
        req.destroy();
        reject(new Error('Request timeout'));
      });

      req.end();
    });
  }

  /**
   * Get fallback content for home page
   * @static
   */
  static getDefaultHomePageContent() {
    return {
      heading: 'Hello World!',
      description: 'Welcome to our multi-platform demo showcasing C# (.NET), Node.js, Python, Java, Go, and Rust implementations.',
      canvasSectionTitle: 'Collaborative Canvas',
      canvasDescription: 'Try our real-time collaborative drawing canvas! Draw together with others across different platforms.',
      launchCanvasButtonText: 'Launch Canvas',
      showQrCodeSection: true,
      qrCodeButtonText: 'Show QR Codes',
      platformLinksTitle: 'Try Other Platforms',
      showPlatformNavigation: true,
      showServerInfo: true,
      backgroundGradientStart: '#667eea',
      backgroundGradientEnd: '#764ba2',
      seoTitle: 'Multi-Platform Demo',
      seoDescription: 'A demonstration of the same application built with multiple platforms.',
      seoKeywords: 'multi-platform, demo'
    };
  }
}

module.exports = UmbracoClient;
