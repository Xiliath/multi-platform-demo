var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

string GetHtmlContent()
{
    var template = File.ReadAllText("../shared/templates/index.html");
    return template
        .Replace("{{PLATFORM}}", "C# (.NET 9.0)")
        .Replace("{{VERSION}}", Environment.Version.ToString())
        .Replace("{{TIMESTAMP}}", DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss UTC"))
        .Replace("{{CANVAS_LINK}}", "/canvas")
        .Replace("{{DOTNET_ACTIVE}}", "active")
        .Replace("{{NODEJS_ACTIVE}}", "")
        .Replace("{{PYTHON_ACTIVE}}", "")
        .Replace("{{JAVA_ACTIVE}}", "")
        .Replace("{{GO_ACTIVE}}", "")
        .Replace("{{RUST_ACTIVE}}", "");
}

string GetCanvasContent()
{
    var template = File.ReadAllText("../shared/templates/canvas.html");
    return template.Replace("{{PLATFORM}}", "C# (.NET 9.0)");
}

string GetJoinContent()
{
    return File.ReadAllText("../shared/templates/join.html");
}

string GetRegistrationContent()
{
    var template = File.ReadAllText("../shared/templates/registration.html");
    return template.Replace("{{PLATFORM}}", "C# (.NET 9.0)");
}

string GetAdminContent()
{
    var template = File.ReadAllText("../shared/templates/admin.html");
    return template.Replace("{{PLATFORM}}", "C# (.NET 9.0)");
}

string GetRegisterQrContent()
{
    return File.ReadAllText("../shared/templates/register-qr.html");
}

app.MapGet("/", () => Results.Content(GetHtmlContent(), "text/html"));
app.MapGet("/canvas", () => Results.Content(GetCanvasContent(), "text/html"));
app.MapGet("/join", () => Results.Content(GetJoinContent(), "text/html"));
app.MapGet("/registration", () => Results.Content(GetRegistrationContent(), "text/html"));
app.MapGet("/admin", () => Results.Content(GetAdminContent(), "text/html"));
app.MapGet("/register-qr", () => Results.Content(GetRegisterQrContent(), "text/html"));

app.Run();
