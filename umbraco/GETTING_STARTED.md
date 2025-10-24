# Getting Started with Umbraco Heartcore

This guide will walk you through setting up Umbraco Heartcore for your multi-platform demo project.

## Quick Start

### Step 1: Create an Umbraco Heartcore Account

1. Go to [umbraco.com/heartcore](https://umbraco.com/products/umbraco-heartcore/)
2. Sign up for a free trial or paid account
3. Create a new Heartcore project
4. Choose a project alias (e.g., `multi-platform-demo`)

### Step 2: Set Up Content Types

In your Umbraco Heartcore backoffice:

#### Create Home Page Content Type

1. Navigate to **Settings** → **Document Types**
2. Click **Create** → **Document Type**
3. Configure:
   - Name: `Home Page`
   - Alias: `homePage`
   - Icon: `icon-home`
   - Allow at root: ✓

4. Add tabs and properties from `/umbraco/content-types/homePage.json`:

**Content Tab:**
- Heading (Textstring) - Main heading
- Description (Textarea) - Brief description
- Canvas Section Title (Textstring)
- Canvas Description (Textarea)
- Launch Canvas Button Text (Textstring)
- Show QR Code Section (True/false)
- QR Code Button Text (Textstring)
- Platform Links Title (Textstring)

**Settings Tab:**
- Show Platform Navigation (True/false)
- Show Server Info (True/false)

**Styling Tab:**
- Custom CSS (Textarea)
- Background Gradient Start (Textstring with pattern: `^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$`)
- Background Gradient End (Textstring with pattern: `^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$`)

**SEO Tab:**
- SEO Title (Textstring)
- SEO Description (Textarea)
- SEO Keywords (Textstring)

5. Save the document type

#### Create Platform Config Content Type (Optional)

Follow similar steps for the Platform Config content type defined in `/umbraco/content-types/platformConfig.json`.

### Step 3: Create Content

1. Navigate to **Content** in the Umbraco backoffice
2. Click **Create** → **Home Page**
3. Fill in the content:
   - Heading: `Hello World!`
   - Description: `Welcome to our multi-platform demo showcasing C# (.NET), Node.js, Python, Java, Go, and Rust implementations.`
   - Canvas Section Title: `Collaborative Canvas`
   - Canvas Description: `Try our real-time collaborative drawing canvas! Draw together with others across different platforms.`
   - (Fill other fields as desired)
4. Click **Save and Publish**

### Step 4: Get API Credentials

1. In Umbraco Heartcore backoffice, go to **Settings** → **Headless**
2. Click **API Keys**
3. Create a new API key for Content Delivery
4. Copy the API key (you won't be able to see it again!)
5. Note your project alias (shown in the URL or project settings)

### Step 5: Configure Environment Variables

1. Create a `.env` file in the project root:
   ```bash
   cp umbraco/config/.env.example .env
   ```

2. Edit `.env` and add your credentials:
   ```env
   UMBRACO_PROJECT_ALIAS=your-project-alias
   UMBRACO_API_KEY=your-api-key-here
   UMBRACO_API_URL=https://cdn.umbraco.io
   UMBRACO_ENABLED=true
   UMBRACO_CACHE_TTL=300
   UMBRACO_FALLBACK_ENABLED=true
   ```

3. **Important**: Add `.env` to `.gitignore` to prevent committing credentials

### Step 6: Update Docker Compose (Optional)

If you want to load environment variables in Docker, update `docker-compose.yml`:

```yaml
services:
  dotnet:
    env_file:
      - .env
    # ... rest of config

  nodejs:
    env_file:
      - .env
    # ... rest of config

  # ... repeat for other services
```

### Step 7: Test the Integration

Test each platform individually:

#### Node.js
```bash
cd umbraco/api-clients/nodejs
node -e "
const UmbracoClient = require('./umbraco-client');
const client = new UmbracoClient();
client.fetchHomePage().then(data => {
  console.log('Heading:', data.heading);
}).catch(err => {
  console.error('Error:', err.message);
  const fallback = UmbracoClient.getDefaultHomePageContent();
  console.log('Fallback heading:', fallback.heading);
});
"
```

#### Python
```bash
cd umbraco/api-clients/python
python3 -c "
import asyncio
from umbraco_client import UmbracoClient

async def test():
    client = UmbracoClient()
    try:
        data = await client.fetch_home_page()
        print('Heading:', data['heading'])
    except Exception as e:
        print('Error:', str(e))
        fallback = UmbracoClient.get_default_home_page_content()
        print('Fallback heading:', fallback['heading'])

asyncio.run(test())
"
```

## Integration Examples

### Integrating into Each Platform

Each platform directory contains an API client ready to use. Here's how to integrate them:

#### Node.js (`/nodejs/server.js`)

```javascript
const UmbracoClient = require('../umbraco/api-clients/nodejs/umbraco-client');
const client = new UmbracoClient();

async function renderHomePage() {
  let content;
  try {
    content = await client.fetchHomePage();
  } catch (error) {
    console.error('Umbraco error:', error.message);
    content = UmbracoClient.getDefaultHomePageContent();
  }

  // Use content.heading, content.description, etc.
  // in your template rendering
}
```

#### Python (`/python/app.py`)

```python
from umbraco.api_clients.python.umbraco_client import UmbracoClient

client = UmbracoClient()

@app.route('/')
def home():
    try:
        content = client.fetch_home_page()
    except Exception as e:
        print(f'Umbraco error: {e}')
        content = UmbracoClient.get_default_home_page_content()

    # Use content in your template
    return render_template('index.html', **content)
```

#### C# (.NET) (`/dotnet/Program.cs`)

```csharp
using MultiPlatformDemo.Umbraco;

var client = new UmbracoClient();

app.MapGet("/", async () =>
{
    Dictionary<string, object> content;
    try
    {
        var data = await client.FetchHomePageAsync();
        content = JsonSerializer.Deserialize<Dictionary<string, object>>(data.ToString());
    }
    catch (Exception ex)
    {
        Console.Error.WriteLine($"Umbraco error: {ex.Message}");
        content = UmbracoClient.GetDefaultHomePageContent();
    }

    // Use content in your response
});
```

## Content Management Workflow

1. **Edit Content**: Log into Umbraco Heartcore backoffice
2. **Make Changes**: Update text, settings, or styling
3. **Publish**: Click "Save and Publish"
4. **View Changes**: Content is available via API immediately
5. **Platform Updates**: Each platform will fetch new content (within cache TTL)

## Caching Strategy

- Default cache TTL: **5 minutes** (300 seconds)
- Cached content is served from memory
- If API fails, expired cache is used as fallback
- Manual cache clear: Call `client.clearCache()` in your platform code

## Troubleshooting

### API Returns 401 Unauthorized
- Check your API key is correct
- Verify the project alias matches your Heartcore project
- Ensure the API key has Content Delivery permissions

### API Returns 404 Not Found
- Verify you've created and published the "Home Page" content
- Check the content type alias is exactly `homePage`
- Ensure content is published (not just saved as draft)

### Content Not Updating
- Check cache TTL - wait for cache to expire
- Manually clear cache in your application
- Verify you published (not just saved) in Umbraco

### Environment Variables Not Loading
- Check `.env` file exists in project root
- Verify docker-compose.yml includes `env_file: - .env`
- Restart Docker containers after changing .env

## Advanced Features

### Multiple Environments

Create separate `.env` files for different environments:

```bash
.env.development
.env.staging
.env.production
```

Load the appropriate one based on environment.

### Content Preview

For content preview (unpublished content), you'll need:
1. Preview API key (different from Content Delivery)
2. Different API endpoint
3. Authentication for editors

### Webhooks

Set up webhooks in Umbraco Heartcore to:
- Clear cache when content is published
- Trigger rebuilds
- Send notifications

## Resources

- [Umbraco Heartcore Documentation](https://docs.umbraco.com/umbraco-heartcore/)
- [Content Delivery API Reference](https://docs.umbraco.com/umbraco-heartcore/api-documentation/content-delivery)
- [Umbraco Community Forum](https://our.umbraco.com/)

## Next Steps

1. ✅ Set up Umbraco Heartcore account
2. ✅ Create content types
3. ✅ Add initial content
4. ✅ Configure environment variables
5. ⬜ Integrate clients into platform code
6. ⬜ Test with Docker Compose
7. ⬜ Deploy to production
