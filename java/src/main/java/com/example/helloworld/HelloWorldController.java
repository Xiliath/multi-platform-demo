package com.example.helloworld;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;

@RestController
public class HelloWorldController {

    private String getHtmlContent() throws IOException {
        String template = Files.readString(Paths.get("../shared/templates/index.html"));
        String javaVersion = System.getProperty("java.version");
        String timestamp = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
                .withZone(ZoneOffset.UTC)
                .format(Instant.now()) + " UTC";

        return template
                .replace("{{PLATFORM}}", "Java (Spring Boot)")
                .replace("{{VERSION}}", javaVersion)
                .replace("{{TIMESTAMP}}", timestamp)
                .replace("{{CANVAS_LINK}}", "/java/canvas")
                .replace("{{DOTNET_ACTIVE}}", "")
                .replace("{{NODEJS_ACTIVE}}", "")
                .replace("{{PYTHON_ACTIVE}}", "")
                .replace("{{JAVA_ACTIVE}}", "active")
                .replace("{{GO_ACTIVE}}", "")
                .replace("{{RUST_ACTIVE}}", "");
    }

    private String getCanvasContent() throws IOException {
        String template = Files.readString(Paths.get("../shared/templates/canvas.html"));
        return template.replace("{{PLATFORM}}", "Java (Spring Boot)");
    }

    @GetMapping(value = {"/", "/java"}, produces = "text/html")
    public String hello() throws IOException {
        return getHtmlContent();
    }

    @GetMapping(value = {"/canvas", "/java/canvas"}, produces = "text/html")
    public String canvas() throws IOException {
        return getCanvasContent();
    }

    @GetMapping(value = {"/join", "/java/join"}, produces = "text/html")
    public String join() throws IOException {
        return Files.readString(Paths.get("../shared/templates/join.html"));
    }

    @GetMapping(value = {"/registration", "/java/registration"}, produces = "text/html")
    public String registration() throws IOException {
        String template = Files.readString(Paths.get("../shared/templates/registration.html"));
        return template.replace("{{PLATFORM}}", "Java (Spring Boot)");
    }

    @GetMapping(value = {"/admin", "/java/admin"}, produces = "text/html")
    public String admin() throws IOException {
        String template = Files.readString(Paths.get("../shared/templates/admin.html"));
        return template.replace("{{PLATFORM}}", "Java (Spring Boot)");
    }

    @GetMapping(value = {"/register-qr", "/java/register-qr"}, produces = "text/html")
    public String registerQr() throws IOException {
        return Files.readString(Paths.get("../shared/templates/register-qr.html"));
    }
}
