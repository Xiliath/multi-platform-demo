package umbraco

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"
)

// Client for Umbraco Heartcore Content Delivery API
type Client struct {
	ProjectAlias    string
	APIKey          string
	APIURL          string
	Enabled         bool
	CacheTTL        time.Duration
	FallbackEnabled bool
	httpClient      *http.Client
	cache           map[string]*cacheEntry
	cacheMux        sync.RWMutex
}

type cacheEntry struct {
	Data      interface{}
	Timestamp time.Time
}

// Config for initializing the Umbraco client
type Config struct {
	ProjectAlias    string
	APIKey          string
	APIURL          string
	Enabled         *bool
	CacheTTL        *int
	FallbackEnabled *bool
}

// NewClient creates a new Umbraco Heartcore client
func NewClient(config *Config) *Client {
	if config == nil {
		config = &Config{}
	}

	projectAlias := config.ProjectAlias
	if projectAlias == "" {
		projectAlias = os.Getenv("UMBRACO_PROJECT_ALIAS")
	}

	apiKey := config.APIKey
	if apiKey == "" {
		apiKey = os.Getenv("UMBRACO_API_KEY")
	}

	apiURL := config.APIURL
	if apiURL == "" {
		apiURL = os.Getenv("UMBRACO_API_URL")
		if apiURL == "" {
			apiURL = "https://cdn.umbraco.io"
		}
	}

	enabled := true
	if config.Enabled != nil {
		enabled = *config.Enabled
	} else if os.Getenv("UMBRACO_ENABLED") == "false" {
		enabled = false
	}

	cacheTTL := 300
	if config.CacheTTL != nil {
		cacheTTL = *config.CacheTTL
	} else if ttl := os.Getenv("UMBRACO_CACHE_TTL"); ttl != "" {
		if parsed, err := strconv.Atoi(ttl); err == nil {
			cacheTTL = parsed
		}
	}

	fallbackEnabled := true
	if config.FallbackEnabled != nil {
		fallbackEnabled = *config.FallbackEnabled
	} else if os.Getenv("UMBRACO_FALLBACK_ENABLED") == "false" {
		fallbackEnabled = false
	}

	return &Client{
		ProjectAlias:    projectAlias,
		APIKey:          apiKey,
		APIURL:          apiURL,
		Enabled:         enabled,
		CacheTTL:        time.Duration(cacheTTL) * time.Second,
		FallbackEnabled: fallbackEnabled,
		httpClient: &http.Client{
			Timeout: 5 * time.Second,
		},
		cache: make(map[string]*cacheEntry),
	}
}

// FetchContent fetches content from Umbraco Heartcore API
func (c *Client) FetchContent(contentType string, options map[string]string) (map[string]interface{}, error) {
	if !c.Enabled {
		return nil, fmt.Errorf("umbraco client is disabled")
	}

	if c.ProjectAlias == "" || c.APIKey == "" {
		return nil, fmt.Errorf("umbraco project alias and API key are required")
	}

	if options == nil {
		options = make(map[string]string)
	}

	optionsJSON, _ := json.Marshal(options)
	cacheKey := fmt.Sprintf("%s:%s", contentType, string(optionsJSON))

	// Check cache
	c.cacheMux.RLock()
	cached, exists := c.cache[cacheKey]
	c.cacheMux.RUnlock()

	if exists && time.Since(cached.Timestamp) < c.CacheTTL {
		return cached.Data.(map[string]interface{}), nil
	}

	// Make API request
	apiURL := fmt.Sprintf("%s/%s/content/type/%s", c.APIURL, c.ProjectAlias, contentType)
	data, err := c.makeRequest(apiURL, options)

	if err != nil {
		fmt.Fprintf(os.Stderr, "Umbraco API error: %v\n", err)

		// Return cached data if available (even if expired)
		if exists {
			fmt.Println("Using expired cache due to API error")
			return cached.Data.(map[string]interface{}), nil
		}

		return nil, err
	}

	// Extract first content item
	embedded, ok := data["_embedded"].(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("invalid response format: missing _embedded")
	}

	content, ok := embedded["content"].([]interface{})
	if !ok || len(content) == 0 {
		return nil, fmt.Errorf("no content found for type: %s", contentType)
	}

	contentItem := content[0].(map[string]interface{})

	// Cache the result
	c.cacheMux.Lock()
	c.cache[cacheKey] = &cacheEntry{
		Data:      contentItem,
		Timestamp: time.Now(),
	}
	c.cacheMux.Unlock()

	return contentItem, nil
}

// FetchHomePage fetches the home page content
func (c *Client) FetchHomePage() (map[string]interface{}, error) {
	return c.FetchContent("homePage", nil)
}

// FetchPlatformConfigs fetches platform configurations
func (c *Client) FetchPlatformConfigs() ([]map[string]interface{}, error) {
	apiURL := fmt.Sprintf("%s/%s/content/type/platformConfig", c.APIURL, c.ProjectAlias)
	options := map[string]string{"sort": "sortOrder:asc"}

	data, err := c.makeRequest(apiURL, options)
	if err != nil {
		return nil, err
	}

	embedded, ok := data["_embedded"].(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("invalid response format: missing _embedded")
	}

	content, ok := embedded["content"].([]interface{})
	if !ok {
		return []map[string]interface{}{}, nil
	}

	configs := make([]map[string]interface{}, len(content))
	for i, item := range content {
		configs[i] = item.(map[string]interface{})
	}

	return configs, nil
}

// ClearCache clears the cache
func (c *Client) ClearCache() {
	c.cacheMux.Lock()
	c.cache = make(map[string]*cacheEntry)
	c.cacheMux.Unlock()
}

func (c *Client) makeRequest(apiURL string, queryParams map[string]string) (map[string]interface{}, error) {
	// Build query string
	if len(queryParams) > 0 {
		values := url.Values{}
		for key, value := range queryParams {
			values.Add(key, value)
		}
		apiURL = fmt.Sprintf("%s?%s", apiURL, values.Encode())
	}

	// Create request
	req, err := http.NewRequest("GET", apiURL, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Accept", "application/json")
	req.Header.Set("Umb-Project-Alias", c.ProjectAlias)
	req.Header.Set("Api-Key", c.APIKey)

	// Make request
	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	// Read response
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("HTTP %d: %s", resp.StatusCode, string(body))
	}

	// Parse JSON
	var data map[string]interface{}
	if err := json.Unmarshal(body, &data); err != nil {
		return nil, fmt.Errorf("failed to parse JSON response: %w", err)
	}

	return data, nil
}

// GetDefaultHomePageContent returns fallback content for home page
func GetDefaultHomePageContent() map[string]interface{} {
	return map[string]interface{}{
		"heading":                 "Hello World!",
		"description":             "Welcome to our multi-platform demo showcasing C# (.NET), Node.js, Python, Java, Go, and Rust implementations.",
		"canvasSectionTitle":      "Collaborative Canvas",
		"canvasDescription":       "Try our real-time collaborative drawing canvas! Draw together with others across different platforms.",
		"launchCanvasButtonText":  "Launch Canvas",
		"showQrCodeSection":       true,
		"qrCodeButtonText":        "Show QR Codes",
		"platformLinksTitle":      "Try Other Platforms",
		"showPlatformNavigation":  true,
		"showServerInfo":          true,
		"backgroundGradientStart": "#667eea",
		"backgroundGradientEnd":   "#764ba2",
		"seoTitle":                "Multi-Platform Demo",
		"seoDescription":          "A demonstration of the same application built with multiple platforms.",
		"seoKeywords":             "multi-platform, demo",
	}
}
