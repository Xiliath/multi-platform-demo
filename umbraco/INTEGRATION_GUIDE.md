# Platform Integration Guide

This guide shows how to integrate the Umbraco Heartcore API clients into each platform of the multi-platform demo.

## Overview

Each platform has a dedicated API client that:
- Fetches content from Umbraco Heartcore
- Caches responses for performance
- Falls back to default content if API is unavailable
- Uses environment variables for configuration

## Integration by Platform

### 1. Node.js Integration

**File**: `/nodejs/server.js`

#### Install Dependencies (None Required)
The Node.js client uses only built-in modules.

#### Import and Initialize
```javascript
const UmbracoClient = require('../umbraco/api-clients/nodejs/umbraco-client');
const client = new UmbracoClient();
```

#### Fetch Content in Route Handler
```javascript
const http = require('http');
const fs = require('fs');
const path = require('path');
const UmbracoClient = require('../umbraco/api-clients/nodejs/umbraco-client');

const client = new UmbracoClient();

const server = http.createServer(async (req, res) => {
  if (req.url === '/' || req.url === '/nodejs') {
    try {
      // Fetch content from Umbraco
      const content = await client.fetchHomePage();

      // Read template
      const template = fs.readFileSync(
        path.join(__dirname, '../shared/templates/index.html'),
        'utf-8'
      );

      // Replace placeholders with Umbraco content
      let html = template
        .replace(/{{HEADING}}/g, content.heading || 'Hello World!')
        .replace(/{{DESCRIPTION}}/g, content.description || '')
        .replace(/{{PLATFORM}}/g, 'Node.js')
        .replace(/{{VERSION}}/g, process.version)
        .replace(/{{TIMESTAMP}}/g, new Date().toISOString());

      res.writeHead(200, { 'Content-Type': 'text/html' });
      res.end(html);
    } catch (error) {
      console.error('Error fetching Umbraco content:', error.message);

      // Use fallback content
      const fallback = UmbracoClient.getDefaultHomePageContent();

      // ... render with fallback content
    }
  }
});

server.listen(5001);
```

---

### 2. Python Integration

**File**: `/python/app.py`

#### Install Dependencies (None Required)
The Python client uses only standard library modules.

#### Import and Initialize
```python
import sys
import os

# Add umbraco client to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../umbraco/api-clients/python'))

from umbraco_client import UmbracoClient

client = UmbracoClient()
```

#### Fetch Content in Route Handler
```python
from flask import Flask, render_template_string
from datetime import datetime
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../umbraco/api-clients/python'))
from umbraco_client import UmbracoClient

app = Flask(__name__)
client = UmbracoClient()

@app.route('/')
@app.route('/python')
def home():
    try:
        # Fetch content from Umbraco
        content = client.fetch_home_page()
    except Exception as e:
        print(f'Error fetching Umbraco content: {e}')
        # Use fallback content
        content = UmbracoClient.get_default_home_page_content()

    # Read template
    with open('../shared/templates/index.html', 'r') as f:
        template = f.read()

    # Replace placeholders with Umbraco content
    html = template.replace('{{HEADING}}', content.get('heading', 'Hello World!'))
    html = html.replace('{{DESCRIPTION}}', content.get('description', ''))
    html = html.replace('{{PLATFORM}}', 'Python (Flask 3.x)')
    html = html.replace('{{TIMESTAMP}}', datetime.utcnow().isoformat())

    return html

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
```

---

### 3. C# (.NET) Integration

**File**: `/dotnet/Program.cs`

#### Add Client to Project
```bash
cp umbraco/api-clients/dotnet/UmbracoClient.cs dotnet/
```

#### Import and Initialize
```csharp
using MultiPlatformDemo.Umbraco;

var client = new UmbracoClient();
```

#### Fetch Content in Route Handler
```csharp
using System.Text.Json;
using MultiPlatformDemo.Umbraco;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var client = new UmbracoClient();

app.MapGet("/", async () =>
{
    string heading = "Hello World!";
    string description = "";

    try
    {
        // Fetch content from Umbraco
        var content = await client.FetchHomePageAsync();
        heading = content.GetProperty("heading").GetString() ?? heading;
        description = content.GetProperty("description").GetString() ?? "";
    }
    catch (Exception ex)
    {
        Console.Error.WriteLine($"Error fetching Umbraco content: {ex.Message}");
        // Use fallback content
        var fallback = UmbracoClient.GetDefaultHomePageContent();
        heading = fallback["heading"].ToString();
        description = fallback["description"].ToString();
    }

    // Read template
    var template = await File.ReadAllTextAsync("../shared/templates/index.html");

    // Replace placeholders
    var html = template
        .Replace("{{HEADING}}", heading)
        .Replace("{{DESCRIPTION}}", description)
        .Replace("{{PLATFORM}}", "C# (.NET 9.0)")
        .Replace("{{TIMESTAMP}}", DateTime.UtcNow.ToString("o"));

    return Results.Content(html, "text/html");
});

app.Run("http://0.0.0.0:5000");
```

---

### 4. Go Integration

**File**: `/go/main.go`

#### Initialize Go Module
```bash
cd umbraco/api-clients/go
go mod init github.com/yourusername/multi-platform-demo/umbraco
```

#### Import and Initialize
```go
import (
    "github.com/yourusername/multi-platform-demo/umbraco"
)

client := umbraco.NewClient(nil)
```

#### Fetch Content in Route Handler
```go
package main

import (
    "fmt"
    "io/ioutil"
    "net/http"
    "os"
    "strings"
    "time"

    "path/to/umbraco"
)

func main() {
    client := umbraco.NewClient(nil)

    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        var heading = "Hello World!"
        var description = ""

        // Fetch content from Umbraco
        content, err := client.FetchHomePage()
        if err != nil {
            fmt.Fprintf(os.Stderr, "Error fetching Umbraco content: %v\n", err)
            // Use fallback content
            content = umbraco.GetDefaultHomePageContent()
        }

        if h, ok := content["heading"].(string); ok {
            heading = h
        }
        if d, ok := content["description"].(string); ok {
            description = d
        }

        // Read template
        template, _ := ioutil.ReadFile("../shared/templates/index.html")

        // Replace placeholders
        html := string(template)
        html = strings.ReplaceAll(html, "{{HEADING}}", heading)
        html = strings.ReplaceAll(html, "{{DESCRIPTION}}", description)
        html = strings.ReplaceAll(html, "{{PLATFORM}}", "Go 1.23")
        html = strings.ReplaceAll(html, "{{TIMESTAMP}}", time.Now().UTC().Format(time.RFC3339))

        w.Header().Set("Content-Type", "text/html")
        fmt.Fprint(w, html)
    })

    http.ListenAndServe(":5004", nil)
}
```

---

### 5. Java Integration

**File**: `/java/src/main/java/com/demo/HelloWorldApplication.java`

#### Add Dependencies to pom.xml
```xml
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.15.0</version>
</dependency>
```

#### Copy Client to Project
```bash
cp umbraco/api-clients/java/src/main/java/com/demo/UmbracoClient.java \
   java/src/main/java/com/demo/
```

#### Import and Initialize
```java
import com.demo.UmbracoClient;
import com.fasterxml.jackson.databind.JsonNode;
```

#### Fetch Content in Controller
```java
package com.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import com.fasterxml.jackson.databind.JsonNode;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.Instant;

@SpringBootApplication
@RestController
public class HelloWorldApplication {

    private final UmbracoClient umbracoClient = new UmbracoClient();

    @GetMapping("/")
    public String home() {
        String heading = "Hello World!";
        String description = "";

        try {
            // Fetch content from Umbraco
            JsonNode content = umbracoClient.fetchHomePage();
            heading = content.get("heading").asText(heading);
            description = content.get("description").asText("");
        } catch (Exception e) {
            System.err.println("Error fetching Umbraco content: " + e.getMessage());
            // Use fallback content
            var fallback = UmbracoClient.getDefaultHomePageContent();
            heading = (String) fallback.get("heading");
            description = (String) fallback.get("description");
        }

        try {
            // Read template
            String template = new String(Files.readAllBytes(
                Paths.get("../shared/templates/index.html")
            ));

            // Replace placeholders
            String html = template
                .replace("{{HEADING}}", heading)
                .replace("{{DESCRIPTION}}", description)
                .replace("{{PLATFORM}}", "Java (Spring Boot)")
                .replace("{{TIMESTAMP}}", Instant.now().toString());

            return html;
        } catch (Exception e) {
            return "Error loading template: " + e.getMessage();
        }
    }

    public static void main(String[] args) {
        SpringApplication.run(HelloWorldApplication.class, args);
    }
}
```

---

### 6. Rust Integration

**File**: `/rust/src/main.rs`

#### Add Dependencies to Cargo.toml
```toml
[dependencies]
actix-web = "4"
reqwest = { version = "0.11", features = ["json"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tokio = { version = "1", features = ["full"] }
```

#### Copy Client Library
```bash
cp -r umbraco/api-clients/rust/src/* rust/src/
```

#### Import and Initialize
```rust
mod umbraco_client;
use umbraco_client::UmbracoClient;
```

#### Fetch Content in Route Handler
```rust
use actix_web::{web, App, HttpResponse, HttpServer};
use std::fs;
use chrono::Utc;

mod umbraco_client;
use umbraco_client::UmbracoClient;

async fn index() -> HttpResponse {
    let client = UmbracoClient::new(None);

    let mut heading = "Hello World!".to_string();
    let mut description = String::new();

    // Fetch content from Umbraco
    match client.fetch_home_page().await {
        Ok(content) => {
            if let Some(h) = content.get("heading").and_then(|v| v.as_str()) {
                heading = h.to_string();
            }
            if let Some(d) = content.get("description").and_then(|v| v.as_str()) {
                description = d.to_string();
            }
        }
        Err(e) => {
            eprintln!("Error fetching Umbraco content: {}", e);
            // Use fallback content
            let fallback = UmbracoClient::get_default_home_page_content();
            heading = fallback.get("heading").unwrap().as_str().unwrap().to_string();
            description = fallback.get("description").unwrap().as_str().unwrap().to_string();
        }
    }

    // Read template
    let template = fs::read_to_string("../shared/templates/index.html")
        .unwrap_or_else(|_| "Error loading template".to_string());

    // Replace placeholders
    let html = template
        .replace("{{HEADING}}", &heading)
        .replace("{{DESCRIPTION}}", &description)
        .replace("{{PLATFORM}}", "Rust (Actix-web)")
        .replace("{{TIMESTAMP}}", &Utc::now().to_rfc3339());

    HttpResponse::Ok()
        .content_type("text/html")
        .body(html)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(index))
            .route("/rust", web::get().to(index))
    })
    .bind("0.0.0.0:5005")?
    .run()
    .await
}
```

---

## Template Placeholders

You can add these placeholders to your shared templates to use Umbraco content:

```html
<!-- Content from Umbraco -->
{{HEADING}}
{{DESCRIPTION}}
{{CANVAS_SECTION_TITLE}}
{{CANVAS_DESCRIPTION}}
{{LAUNCH_CANVAS_BUTTON_TEXT}}
{{QR_CODE_BUTTON_TEXT}}
{{PLATFORM_LINKS_TITLE}}

<!-- Platform-specific (not from Umbraco) -->
{{PLATFORM}}
{{VERSION}}
{{TIMESTAMP}}
{{CANVAS_LINK}}
```

## Error Handling Best Practices

1. **Always use try-catch**: Wrap Umbraco API calls in error handling
2. **Log errors**: Help with debugging in production
3. **Use fallback content**: Ensure site stays functional if API is down
4. **Set reasonable timeouts**: Default is 5 seconds
5. **Monitor cache hit rates**: Adjust TTL based on usage patterns

## Testing Integration

Test each platform individually:

```bash
# Test Node.js
curl http://localhost:5001/

# Test Python
curl http://localhost:5002/python

# Test .NET
curl http://localhost:5000/

# Test Java
curl http://localhost:5003/java

# Test Go
curl http://localhost:5004/go

# Test Rust
curl http://localhost:5005/rust
```

Check the response contains content from Umbraco (or fallback content if not configured).

## Performance Considerations

- **Caching**: Default 5-minute cache reduces API calls
- **Async/Await**: Use async where supported (Node.js, Python asyncio, C#, Rust)
- **Connection Pooling**: Clients reuse HTTP connections
- **Timeout**: 5-second timeout prevents hanging requests
- **Fallback**: Expired cache used if API is slow/down

## Next Steps

1. Update each platform's code with the integration examples above
2. Test locally with `docker-compose up`
3. Verify content appears correctly
4. Try editing content in Umbraco and see it update (after cache expires)
5. Deploy to production
