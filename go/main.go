package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
	"strings"
	"time"
)

func getHtmlContent() (string, error) {
	data, err := os.ReadFile("../shared/templates/index.html")
	if err != nil {
		return "", err
	}

	template := string(data)
	timestamp := time.Now().UTC().Format("2006-01-02 15:04:05") + " UTC"

	html := strings.NewReplacer(
		"{{PLATFORM}}", "Go",
		"{{VERSION}}", runtime.Version(),
		"{{TIMESTAMP}}", timestamp,
		"{{CANVAS_LINK}}", "/go/canvas",
		"{{DOTNET_ACTIVE}}", "",
		"{{NODEJS_ACTIVE}}", "",
		"{{PYTHON_ACTIVE}}", "",
		"{{JAVA_ACTIVE}}", "",
		"{{GO_ACTIVE}}", "active",
		"{{RUST_ACTIVE}}", "",
	).Replace(template)

	return html, nil
}

func getCanvasContent() (string, error) {
	data, err := os.ReadFile("../shared/templates/canvas.html")
	if err != nil {
		return "", err
	}

	template := string(data)
	html := strings.Replace(template, "{{PLATFORM}}", "Go", -1)

	return html, nil
}

func handler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path == "/" || r.URL.Path == "/go" {
		html, err := getHtmlContent()
		if err != nil {
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			log.Printf("Error reading template: %v", err)
			return
		}

		w.Header().Set("Content-Type", "text/html")
		fmt.Fprint(w, html)
	} else if r.URL.Path == "/canvas" || r.URL.Path == "/go/canvas" {
		html, err := getCanvasContent()
		if err != nil {
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			log.Printf("Error reading canvas template: %v", err)
			return
		}

		w.Header().Set("Content-Type", "text/html")
		fmt.Fprint(w, html)
	} else if r.URL.Path == "/join" || r.URL.Path == "/go/join" {
		data, err := os.ReadFile("../shared/templates/join.html")
		if err != nil {
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			log.Printf("Error reading join template: %v", err)
			return
		}

		w.Header().Set("Content-Type", "text/html")
		fmt.Fprint(w, string(data))
	} else if r.URL.Path == "/registration" || r.URL.Path == "/go/registration" {
		data, err := os.ReadFile("../shared/templates/registration.html")
		if err != nil {
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			log.Printf("Error reading registration template: %v", err)
			return
		}

		html := strings.Replace(string(data), "{{PLATFORM}}", "Go", -1)
		w.Header().Set("Content-Type", "text/html")
		fmt.Fprint(w, html)
	} else if r.URL.Path == "/admin" || r.URL.Path == "/go/admin" {
		data, err := os.ReadFile("../shared/templates/admin.html")
		if err != nil {
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			log.Printf("Error reading admin template: %v", err)
			return
		}

		html := strings.Replace(string(data), "{{PLATFORM}}", "Go", -1)
		w.Header().Set("Content-Type", "text/html")
		fmt.Fprint(w, html)
	} else if r.URL.Path == "/blocked" || r.URL.Path == "/go/blocked" {
		data, err := os.ReadFile("../shared/templates/blocked.html")
		if err != nil {
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			log.Printf("Error reading blocked template: %v", err)
			return
		}

		w.Header().Set("Content-Type", "text/html")
		fmt.Fprint(w, string(data))
	} else {
		http.NotFound(w, r)
	}
}

func main() {
	http.HandleFunc("/", handler)

	port := ":5004"
	log.Printf("Go server running on port %s", port)
	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatal(err)
	}
}
