#!/bin/bash

set -euo pipefail

echo "🔧 Building the Go project..."
go build -v ./...

echo "✅ Build succeeded."

echo "🔍 Running golangci-lint..."

LINT_OUTPUT_FILE="/harness/lint-output.txt"

if ! command -v golangci-lint &> /dev/null; then
    echo "❌ golangci-lint not found. Please install it: https://golangci-lint.run/usage/install/"
    exit 1
fi

if golangci-lint run ./... | tee "$LINT_OUTPUT_FILE"; then
    echo "✅ Linting passed."
    exit 0
else
    echo "❌ Linting failed."
    exit 1
fi
