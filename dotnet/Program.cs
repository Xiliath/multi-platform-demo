var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

string GetHtmlContent()
{
    var template = File.ReadAllText("../shared/templates/index.html");
    return template
        .Replace("{{PLATFORM}}", "C# (.NET 9.0)")
        .Replace("{{VERSION}}", Environment.Version.ToString())
        .Replace("{{TIMESTAMP}}", DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss UTC"))
        .Replace("{{DOTNET_ACTIVE}}", "active")
        .Replace("{{NODEJS_ACTIVE}}", "")
        .Replace("{{PYTHON_ACTIVE}}", "")
        .Replace("{{JAVA_ACTIVE}}", "")
        .Replace("{{GO_ACTIVE}}", "");
}

app.MapGet("/", () => Results.Content(GetHtmlContent(), "text/html"));

app.Run();
