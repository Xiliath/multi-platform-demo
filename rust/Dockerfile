# Rust Implementation
FROM rust:1.82 as builder

WORKDIR /app

# Copy Cargo files
COPY rust/Cargo.toml rust/Cargo.lock* ./

# Create a dummy main.rs to cache dependencies
RUN mkdir src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release || true

# Remove the dummy build artifacts to force a clean rebuild
RUN rm -rf target/release/.fingerprint/hello-world-*
RUN rm -f target/release/hello-world target/release/hello-world.d

# Copy the actual source code
COPY rust/src ./src

# Build the application (this will now rebuild with the real code)
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy the binary from builder
COPY --from=builder /app/target/release/hello-world /app/hello-world

# Copy shared templates
COPY shared /shared

# Expose port
EXPOSE 5005

# Run the application
CMD ["/app/hello-world"]
