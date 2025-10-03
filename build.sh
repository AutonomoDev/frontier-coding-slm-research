#!/bin/bash

# Check if cargo exists
if ! command -v cargo &> /dev/null; then
    echo "Error: cargo not found. Please install Rust first: https://rustup.rs/" >&2
    exit 1
fi
rm -f ./ollama-runner
cd ollama-runner-rust

# Build the project
echo "Building ollama-runner..."
cargo build --release

if [ $? -eq 0 ]; then
    echo "✓ Build successful!"
    echo "Run with: ./ollama-runner <destination> [iterations]"
    cp ./target/release/ollama-runner ../
else
    echo "✗ Build failed!" >&2
    exit 1
fi


