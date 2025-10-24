use std::collections::HashMap;
use std::env;
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};
use serde::{Deserialize, Serialize};
use serde_json::Value;

/// Umbraco Heartcore API Client for Rust
///
/// This client fetches content from Umbraco Heartcore Content Delivery API
/// with built-in caching and fallback support.
pub struct UmbracoClient {
    project_alias: String,
    api_key: String,
    api_url: String,
    enabled: bool,
    cache_ttl: Duration,
    fallback_enabled: bool,
    cache: Arc<Mutex<HashMap<String, CacheEntry>>>,
}

struct CacheEntry {
    data: Value,
    timestamp: Instant,
}

#[derive(Default)]
pub struct UmbracoConfig {
    pub project_alias: Option<String>,
    pub api_key: Option<String>,
    pub api_url: Option<String>,
    pub enabled: Option<bool>,
    pub cache_ttl: Option<u64>,
    pub fallback_enabled: Option<bool>,
}

#[derive(Deserialize)]
struct ApiResponse {
    _embedded: Embedded,
}

#[derive(Deserialize)]
struct Embedded {
    content: Vec<Value>,
}

impl UmbracoClient {
    /// Create a new Umbraco Heartcore client
    pub fn new(config: Option<UmbracoConfig>) -> Self {
        let config = config.unwrap_or_default();

        let project_alias = config.project_alias
            .or_else(|| env::var("UMBRACO_PROJECT_ALIAS").ok())
            .unwrap_or_default();

        let api_key = config.api_key
            .or_else(|| env::var("UMBRACO_API_KEY").ok())
            .unwrap_or_default();

        let api_url = config.api_url
            .or_else(|| env::var("UMBRACO_API_URL").ok())
            .unwrap_or_else(|| "https://cdn.umbraco.io".to_string());

        let enabled = config.enabled.unwrap_or_else(|| {
            env::var("UMBRACO_ENABLED")
                .unwrap_or_else(|_| "true".to_string())
                .to_lowercase() != "false"
        });

        let cache_ttl_secs = config.cache_ttl.unwrap_or_else(|| {
            env::var("UMBRACO_CACHE_TTL")
                .ok()
                .and_then(|s| s.parse().ok())
                .unwrap_or(300)
        });

        let fallback_enabled = config.fallback_enabled.unwrap_or_else(|| {
            env::var("UMBRACO_FALLBACK_ENABLED")
                .unwrap_or_else(|_| "true".to_string())
                .to_lowercase() != "false"
        });

        Self {
            project_alias,
            api_key,
            api_url,
            enabled,
            cache_ttl: Duration::from_secs(cache_ttl_secs),
            fallback_enabled,
            cache: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    /// Fetch content from Umbraco Heartcore API
    pub async fn fetch_content(
        &self,
        content_type: &str,
        options: Option<HashMap<String, String>>,
    ) -> Result<Value, Box<dyn std::error::Error>> {
        if !self.enabled {
            return Err("Umbraco client is disabled".into());
        }

        if self.project_alias.is_empty() || self.api_key.is_empty() {
            return Err("Umbraco project alias and API key are required".into());
        }

        let options = options.unwrap_or_default();
        let cache_key = format!("{}:{}", content_type, serde_json::to_string(&options)?);

        // Check cache
        {
            let cache = self.cache.lock().unwrap();
            if let Some(cached) = cache.get(&cache_key) {
                if cached.timestamp.elapsed() < self.cache_ttl {
                    return Ok(cached.data.clone());
                }
            }
        }

        // Make API request
        let url = format!("{}/{}/content/type/{}", self.api_url, self.project_alias, content_type);

        match self.make_request(&url, &options).await {
            Ok(response) => {
                // Extract first content item
                let content = response._embedded.content
                    .get(0)
                    .ok_or("No content found")?
                    .clone();

                // Cache the result
                {
                    let mut cache = self.cache.lock().unwrap();
                    cache.insert(cache_key.clone(), CacheEntry {
                        data: content.clone(),
                        timestamp: Instant::now(),
                    });
                }

                Ok(content)
            }
            Err(err) => {
                eprintln!("Umbraco API error: {}", err);

                // Return cached data if available (even if expired)
                let cache = self.cache.lock().unwrap();
                if let Some(cached) = cache.get(&cache_key) {
                    println!("Using expired cache due to API error");
                    return Ok(cached.data.clone());
                }

                Err(err)
            }
        }
    }

    /// Fetch the home page content
    pub async fn fetch_home_page(&self) -> Result<Value, Box<dyn std::error::Error>> {
        self.fetch_content("homePage", None).await
    }

    /// Fetch platform configurations
    pub async fn fetch_platform_configs(&self) -> Result<Vec<Value>, Box<dyn std::error::Error>> {
        let url = format!("{}/{}/content/type/platformConfig", self.api_url, self.project_alias);
        let mut options = HashMap::new();
        options.insert("sort".to_string(), "sortOrder:asc".to_string());

        let response = self.make_request(&url, &options).await?;
        Ok(response._embedded.content)
    }

    /// Clear the cache
    pub fn clear_cache(&self) {
        let mut cache = self.cache.lock().unwrap();
        cache.clear();
    }

    async fn make_request(
        &self,
        url: &str,
        query_params: &HashMap<String, String>,
    ) -> Result<ApiResponse, Box<dyn std::error::Error>> {
        let client = reqwest::Client::builder()
            .timeout(Duration::from_secs(5))
            .build()?;

        let mut request = client
            .get(url)
            .header("Accept", "application/json")
            .header("Umb-Project-Alias", &self.project_alias)
            .header("Api-Key", &self.api_key);

        // Add query parameters
        if !query_params.is_empty() {
            request = request.query(query_params);
        }

        let response = request.send().await?;

        if !response.status().is_success() {
            let status = response.status();
            let body = response.text().await?;
            return Err(format!("HTTP {}: {}", status, body).into());
        }

        let data = response.json::<ApiResponse>().await?;
        Ok(data)
    }

    /// Get fallback content for home page
    pub fn get_default_home_page_content() -> HashMap<String, Value> {
        let mut content = HashMap::new();
        content.insert("heading".to_string(), Value::String("Hello World!".to_string()));
        content.insert("description".to_string(), Value::String("Welcome to our multi-platform demo showcasing C# (.NET), Node.js, Python, Java, Go, and Rust implementations.".to_string()));
        content.insert("canvasSectionTitle".to_string(), Value::String("Collaborative Canvas".to_string()));
        content.insert("canvasDescription".to_string(), Value::String("Try our real-time collaborative drawing canvas! Draw together with others across different platforms.".to_string()));
        content.insert("launchCanvasButtonText".to_string(), Value::String("Launch Canvas".to_string()));
        content.insert("showQrCodeSection".to_string(), Value::Bool(true));
        content.insert("qrCodeButtonText".to_string(), Value::String("Show QR Codes".to_string()));
        content.insert("platformLinksTitle".to_string(), Value::String("Try Other Platforms".to_string()));
        content.insert("showPlatformNavigation".to_string(), Value::Bool(true));
        content.insert("showServerInfo".to_string(), Value::Bool(true));
        content.insert("backgroundGradientStart".to_string(), Value::String("#667eea".to_string()));
        content.insert("backgroundGradientEnd".to_string(), Value::String("#764ba2".to_string()));
        content.insert("seoTitle".to_string(), Value::String("Multi-Platform Demo".to_string()));
        content.insert("seoDescription".to_string(), Value::String("A demonstration of the same application built with multiple platforms.".to_string()));
        content.insert("seoKeywords".to_string(), Value::String("multi-platform, demo".to_string()));
        content
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_default_content() {
        let content = UmbracoClient::get_default_home_page_content();
        assert_eq!(content.get("heading").unwrap(), &Value::String("Hello World!".to_string()));
    }
}
