#!/bin/sh

set -euo pipefail

echo "🔧 Building the Go project..."
go build -v ./...

echo "✅ Build succeeded."

echo "🔍 Running golangci-lint..."
if ! command -v golangci-lint &> /dev/null; then
    echo "❌ golangci-lint not found. Please install it: https://golangci-lint.run/usage/install/"
    exit 1
fi

golangci-lint run ./...

echo "✅ Linting passed."
