package com.demo;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Umbraco Heartcore API Client for Java
 *
 * This client fetches content from Umbraco Heartcore Content Delivery API
 * with built-in caching and fallback support.
 */
public class UmbracoClient {
    private final String projectAlias;
    private final String apiKey;
    private final String apiUrl;
    private final boolean enabled;
    private final int cacheTtl;
    private final boolean fallbackEnabled;
    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;
    private final Map<String, CacheEntry> cache;

    public UmbracoClient(UmbracoConfig config) {
        if (config == null) {
            config = new UmbracoConfig();
        }

        this.projectAlias = config.getProjectAlias() != null ? config.getProjectAlias()
            : System.getenv("UMBRACO_PROJECT_ALIAS");
        this.apiKey = config.getApiKey() != null ? config.getApiKey()
            : System.getenv("UMBRACO_API_KEY");
        this.apiUrl = config.getApiUrl() != null ? config.getApiUrl()
            : System.getenv().getOrDefault("UMBRACO_API_URL", "https://cdn.umbraco.io");

        String enabledEnv = System.getenv("UMBRACO_ENABLED");
        this.enabled = config.getEnabled() != null ? config.getEnabled()
            : !"false".equalsIgnoreCase(enabledEnv);

        String cacheTtlEnv = System.getenv("UMBRACO_CACHE_TTL");
        this.cacheTtl = config.getCacheTtl() != null ? config.getCacheTtl()
            : (cacheTtlEnv != null ? Integer.parseInt(cacheTtlEnv) : 300);

        String fallbackEnv = System.getenv("UMBRACO_FALLBACK_ENABLED");
        this.fallbackEnabled = config.getFallbackEnabled() != null ? config.getFallbackEnabled()
            : !"false".equalsIgnoreCase(fallbackEnv);

        this.httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(5))
            .build();
        this.objectMapper = new ObjectMapper();
        this.cache = new HashMap<>();
    }

    public UmbracoClient() {
        this(new UmbracoConfig());
    }

    /**
     * Fetch content from Umbraco Heartcore API
     */
    public JsonNode fetchContent(String contentType, Map<String, String> options) throws Exception {
        if (!enabled) {
            throw new Exception("Umbraco client is disabled");
        }

        if (projectAlias == null || projectAlias.isEmpty() || apiKey == null || apiKey.isEmpty()) {
            throw new Exception("Umbraco project alias and API key are required");
        }

        if (options == null) {
            options = new HashMap<>();
        }

        String cacheKey = contentType + ":" + objectMapper.writeValueAsString(options);

        // Check cache
        CacheEntry cached = cache.get(cacheKey);
        if (cached != null && Duration.between(cached.timestamp, Instant.now()).getSeconds() < cacheTtl) {
            return cached.data;
        }

        try {
            String url = String.format("%s/%s/content/type/%s", apiUrl, projectAlias, contentType);
            JsonNode data = makeRequest(url, options);

            // Extract first content item
            JsonNode content = data.get("_embedded").get("content").get(0);

            if (content == null) {
                throw new Exception("No content found for type: " + contentType);
            }

            // Cache the result
            cache.put(cacheKey, new CacheEntry(content, Instant.now()));

            return content;
        } catch (Exception e) {
            System.err.println("Umbraco API error: " + e.getMessage());

            // Return cached data if available (even if expired)
            if (cached != null) {
                System.out.println("Using expired cache due to API error");
                return cached.data;
            }

            throw e;
        }
    }

    /**
     * Fetch the home page content
     */
    public JsonNode fetchHomePage() throws Exception {
        return fetchContent("homePage", new HashMap<>());
    }

    /**
     * Fetch platform configurations
     */
    public List<JsonNode> fetchPlatformConfigs() throws Exception {
        String url = String.format("%s/%s/content/type/platformConfig", apiUrl, projectAlias);
        Map<String, String> options = new HashMap<>();
        options.put("sort", "sortOrder:asc");

        JsonNode data = makeRequest(url, options);
        JsonNode content = data.get("_embedded").get("content");

        List<JsonNode> configs = new ArrayList<>();
        if (content.isArray()) {
            content.forEach(configs::add);
        }

        return configs;
    }

    /**
     * Clear the cache
     */
    public void clearCache() {
        cache.clear();
    }

    private JsonNode makeRequest(String url, Map<String, String> queryParams) throws Exception {
        // Build query string
        if (queryParams != null && !queryParams.isEmpty()) {
            String query = queryParams.entrySet().stream()
                .map(e -> URLEncoder.encode(e.getKey(), StandardCharsets.UTF_8) + "=" +
                          URLEncoder.encode(e.getValue(), StandardCharsets.UTF_8))
                .collect(Collectors.joining("&"));
            url = url + "?" + query;
        }

        // Create request
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(url))
            .timeout(Duration.ofSeconds(5))
            .header("Accept", "application/json")
            .header("Umb-Project-Alias", projectAlias)
            .header("Api-Key", apiKey)
            .GET()
            .build();

        // Make request
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new Exception("HTTP " + response.statusCode() + ": " + response.body());
        }

        // Parse JSON
        return objectMapper.readTree(response.body());
    }

    /**
     * Get fallback content for home page
     */
    public static Map<String, Object> getDefaultHomePageContent() {
        Map<String, Object> content = new HashMap<>();
        content.put("heading", "Hello World!");
        content.put("description", "Welcome to our multi-platform demo showcasing C# (.NET), Node.js, Python, Java, Go, and Rust implementations.");
        content.put("canvasSectionTitle", "Collaborative Canvas");
        content.put("canvasDescription", "Try our real-time collaborative drawing canvas! Draw together with others across different platforms.");
        content.put("launchCanvasButtonText", "Launch Canvas");
        content.put("showQrCodeSection", true);
        content.put("qrCodeButtonText", "Show QR Codes");
        content.put("platformLinksTitle", "Try Other Platforms");
        content.put("showPlatformNavigation", true);
        content.put("showServerInfo", true);
        content.put("backgroundGradientStart", "#667eea");
        content.put("backgroundGradientEnd", "#764ba2");
        content.put("seoTitle", "Multi-Platform Demo");
        content.put("seoDescription", "A demonstration of the same application built with multiple platforms.");
        content.put("seoKeywords", "multi-platform, demo");
        return content;
    }

    private static class CacheEntry {
        JsonNode data;
        Instant timestamp;

        CacheEntry(JsonNode data, Instant timestamp) {
            this.data = data;
            this.timestamp = timestamp;
        }
    }

    public static class UmbracoConfig {
        private String projectAlias;
        private String apiKey;
        private String apiUrl;
        private Boolean enabled;
        private Integer cacheTtl;
        private Boolean fallbackEnabled;

        public String getProjectAlias() { return projectAlias; }
        public void setProjectAlias(String projectAlias) { this.projectAlias = projectAlias; }

        public String getApiKey() { return apiKey; }
        public void setApiKey(String apiKey) { this.apiKey = apiKey; }

        public String getApiUrl() { return apiUrl; }
        public void setApiUrl(String apiUrl) { this.apiUrl = apiUrl; }

        public Boolean getEnabled() { return enabled; }
        public void setEnabled(Boolean enabled) { this.enabled = enabled; }

        public Integer getCacheTtl() { return cacheTtl; }
        public void setCacheTtl(Integer cacheTtl) { this.cacheTtl = cacheTtl; }

        public Boolean getFallbackEnabled() { return fallbackEnabled; }
        public void setFallbackEnabled(Boolean fallbackEnabled) { this.fallbackEnabled = fallbackEnabled; }
    }
}
