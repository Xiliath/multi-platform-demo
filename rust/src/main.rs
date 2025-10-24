use actix_web::{web, App, HttpResponse, HttpServer};
use std::fs;

fn get_html_content(canvas_path: &str, active_platform: &str) -> String {
    let template = fs::read_to_string("/shared/templates/index.html")
        .expect("Failed to read template");

    let version = env!("CARGO_PKG_VERSION");
    let timestamp = chrono::Utc::now().format("%Y-%m-%d %H:%M:%S UTC").to_string();

    template
        .replace("{{PLATFORM}}", "Rust 1.82")
        .replace("{{VERSION}}", version)
        .replace("{{TIMESTAMP}}", &timestamp)
        .replace("{{CANVAS_LINK}}", canvas_path)
        .replace("{{DOTNET_ACTIVE}}", if active_platform == "dotnet" { "active" } else { "" })
        .replace("{{NODEJS_ACTIVE}}", if active_platform == "nodejs" { "active" } else { "" })
        .replace("{{PYTHON_ACTIVE}}", if active_platform == "python" { "active" } else { "" })
        .replace("{{JAVA_ACTIVE}}", if active_platform == "java" { "active" } else { "" })
        .replace("{{GO_ACTIVE}}", if active_platform == "go" { "active" } else { "" })
        .replace("{{RUST_ACTIVE}}", if active_platform == "rust" { "active" } else { "" })
}

fn get_canvas_content() -> String {
    let template = fs::read_to_string("/shared/templates/canvas.html")
        .expect("Failed to read canvas template");

    template.replace("{{PLATFORM}}", "Rust 1.82")
}

fn get_join_content() -> String {
    fs::read_to_string("/shared/templates/join.html")
        .expect("Failed to read join template")
}

async fn index() -> HttpResponse {
    HttpResponse::Ok()
        .content_type("text/html; charset=utf-8")
        .body(get_html_content("/canvas", "rust"))
}

async fn rust_index() -> HttpResponse {
    HttpResponse::Ok()
        .content_type("text/html; charset=utf-8")
        .body(get_html_content("/rust/canvas", "rust"))
}

async fn canvas() -> HttpResponse {
    HttpResponse::Ok()
        .content_type("text/html; charset=utf-8")
        .body(get_canvas_content())
}

async fn rust_canvas() -> HttpResponse {
    HttpResponse::Ok()
        .content_type("text/html; charset=utf-8")
        .body(get_canvas_content())
}

async fn join() -> HttpResponse {
    HttpResponse::Ok()
        .content_type("text/html; charset=utf-8")
        .body(get_join_content())
}

async fn rust_join() -> HttpResponse {
    HttpResponse::Ok()
        .content_type("text/html; charset=utf-8")
        .body(get_join_content())
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("Starting Rust server on http://0.0.0.0:5005");

    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(index))
            .route("/rust", web::get().to(rust_index))
            .route("/canvas", web::get().to(canvas))
            .route("/rust/canvas", web::get().to(rust_canvas))
            .route("/join", web::get().to(join))
            .route("/rust/join", web::get().to(rust_join))
    })
    .bind(("0.0.0.0", 5005))?
    .run()
    .await
}
