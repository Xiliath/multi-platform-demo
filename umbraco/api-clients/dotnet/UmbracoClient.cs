using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;

namespace MultiPlatformDemo.Umbraco
{
    /// <summary>
    /// Umbraco Heartcore API Client for .NET
    ///
    /// This client fetches content from Umbraco Heartcore Content Delivery API
    /// with built-in caching and fallback support.
    /// </summary>
    public class UmbracoClient
    {
        private readonly string _projectAlias;
        private readonly string _apiKey;
        private readonly string _apiUrl;
        private readonly bool _enabled;
        private readonly int _cacheTtl;
        private readonly bool _fallbackEnabled;
        private readonly HttpClient _httpClient;
        private readonly Dictionary<string, CacheEntry> _cache;

        public UmbracoClient(UmbracoConfig? config = null)
        {
            config ??= new UmbracoConfig();

            _projectAlias = config.ProjectAlias ?? Environment.GetEnvironmentVariable("UMBRACO_PROJECT_ALIAS") ?? "";
            _apiKey = config.ApiKey ?? Environment.GetEnvironmentVariable("UMBRACO_API_KEY") ?? "";
            _apiUrl = config.ApiUrl ?? Environment.GetEnvironmentVariable("UMBRACO_API_URL") ?? "https://cdn.umbraco.io";

            var enabledEnv = Environment.GetEnvironmentVariable("UMBRACO_ENABLED");
            _enabled = config.Enabled ?? (enabledEnv?.ToLower() != "false");

            var cacheTtlEnv = Environment.GetEnvironmentVariable("UMBRACO_CACHE_TTL");
            _cacheTtl = config.CacheTtl ?? (int.TryParse(cacheTtlEnv, out var ttl) ? ttl : 300);

            var fallbackEnv = Environment.GetEnvironmentVariable("UMBRACO_FALLBACK_ENABLED");
            _fallbackEnabled = config.FallbackEnabled ?? (fallbackEnv?.ToLower() != "false");

            _httpClient = new HttpClient
            {
                Timeout = TimeSpan.FromSeconds(5)
            };
            _httpClient.DefaultRequestHeaders.Add("Accept", "application/json");
            _httpClient.DefaultRequestHeaders.Add("Umb-Project-Alias", _projectAlias);
            _httpClient.DefaultRequestHeaders.Add("Api-Key", _apiKey);

            _cache = new Dictionary<string, CacheEntry>();
        }

        /// <summary>
        /// Fetch content from Umbraco Heartcore API
        /// </summary>
        public async Task<JsonElement> FetchContentAsync(string contentType, Dictionary<string, string>? options = null)
        {
            if (!_enabled)
            {
                throw new Exception("Umbraco client is disabled");
            }

            if (string.IsNullOrEmpty(_projectAlias) || string.IsNullOrEmpty(_apiKey))
            {
                throw new Exception("Umbraco project alias and API key are required");
            }

            options ??= new Dictionary<string, string>();
            var cacheKey = $"{contentType}:{JsonSerializer.Serialize(options)}";

            // Check cache
            if (_cache.TryGetValue(cacheKey, out var cached))
            {
                if (DateTime.UtcNow - cached.Timestamp < TimeSpan.FromSeconds(_cacheTtl))
                {
                    return cached.Data;
                }
            }

            try
            {
                var url = $"{_apiUrl}/{_projectAlias}/content/type/{contentType}";
                var response = await MakeRequestAsync(url, options);

                // Extract first content item
                var content = response.GetProperty("_embedded")
                    .GetProperty("content")[0];

                // Cache the result
                _cache[cacheKey] = new CacheEntry
                {
                    Data = content,
                    Timestamp = DateTime.UtcNow
                };

                return content;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"Umbraco API error: {ex.Message}");

                // Return cached data if available (even if expired)
                if (cached != null)
                {
                    Console.WriteLine("Using expired cache due to API error");
                    return cached.Data;
                }

                throw;
            }
        }

        /// <summary>
        /// Fetch the home page content
        /// </summary>
        public async Task<JsonElement> FetchHomePageAsync()
        {
            return await FetchContentAsync("homePage");
        }

        /// <summary>
        /// Fetch platform configurations
        /// </summary>
        public async Task<List<JsonElement>> FetchPlatformConfigsAsync()
        {
            var url = $"{_apiUrl}/{_projectAlias}/content/type/platformConfig";
            var options = new Dictionary<string, string> { { "sort", "sortOrder:asc" } };
            var data = await MakeRequestAsync(url, options);

            var configs = new List<JsonElement>();
            var content = data.GetProperty("_embedded").GetProperty("content");
            foreach (var item in content.EnumerateArray())
            {
                configs.Add(item);
            }

            return configs;
        }

        /// <summary>
        /// Clear the cache
        /// </summary>
        public void ClearCache()
        {
            _cache.Clear();
        }

        private async Task<JsonElement> MakeRequestAsync(string url, Dictionary<string, string>? queryParams = null)
        {
            queryParams ??= new Dictionary<string, string>();

            // Build query string
            if (queryParams.Count > 0)
            {
                var query = string.Join("&", queryParams.Select(kvp =>
                    $"{Uri.EscapeDataString(kvp.Key)}={Uri.EscapeDataString(kvp.Value)}"));
                url = $"{url}?{query}";
            }

            var response = await _httpClient.GetAsync(url);

            if (!response.IsSuccessStatusCode)
            {
                var error = await response.Content.ReadAsStringAsync();
                throw new Exception($"HTTP {(int)response.StatusCode}: {error}");
            }

            var content = await response.Content.ReadAsStringAsync();
            return JsonSerializer.Deserialize<JsonElement>(content);
        }

        /// <summary>
        /// Get fallback content for home page
        /// </summary>
        public static Dictionary<string, object> GetDefaultHomePageContent()
        {
            return new Dictionary<string, object>
            {
                { "heading", "Hello World!" },
                { "description", "Welcome to our multi-platform demo showcasing C# (.NET), Node.js, Python, Java, Go, and Rust implementations." },
                { "canvasSectionTitle", "Collaborative Canvas" },
                { "canvasDescription", "Try our real-time collaborative drawing canvas! Draw together with others across different platforms." },
                { "launchCanvasButtonText", "Launch Canvas" },
                { "showQrCodeSection", true },
                { "qrCodeButtonText", "Show QR Codes" },
                { "platformLinksTitle", "Try Other Platforms" },
                { "showPlatformNavigation", true },
                { "showServerInfo", true },
                { "backgroundGradientStart", "#667eea" },
                { "backgroundGradientEnd", "#764ba2" },
                { "seoTitle", "Multi-Platform Demo" },
                { "seoDescription", "A demonstration of the same application built with multiple platforms." },
                { "seoKeywords", "multi-platform, demo" }
            };
        }

        private class CacheEntry
        {
            public JsonElement Data { get; set; }
            public DateTime Timestamp { get; set; }
        }
    }

    public class UmbracoConfig
    {
        public string? ProjectAlias { get; set; }
        public string? ApiKey { get; set; }
        public string? ApiUrl { get; set; }
        public bool? Enabled { get; set; }
        public int? CacheTtl { get; set; }
        public bool? FallbackEnabled { get; set; }
    }
}
