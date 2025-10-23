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
                .replace("{{DOTNET_ACTIVE}}", "")
                .replace("{{NODEJS_ACTIVE}}", "")
                .replace("{{PYTHON_ACTIVE}}", "")
                .replace("{{JAVA_ACTIVE}}", "active")
                .replace("{{GO_ACTIVE}}", "");
    }

    @GetMapping(value = {"/", "/java"}, produces = "text/html")
    public String hello() throws IOException {
        return getHtmlContent();
    }
}
