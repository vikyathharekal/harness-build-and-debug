FROM golang:1.21-alpine

# Install bash, git, curl, and golangci-lint dependencies
RUN apk add --no-cache bash git curl

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | \
    sh -s -- -b /usr/local/bin v1.56.2

# Copy your script
COPY build-and-debug.sh /usr/local/bin/build-and-debug.sh
RUN chmod +x /usr/local/bin/build-and-debug.sh

# Set working directory (optional)
WORKDIR /app

ENTRYPOINT ["/usr/local/bin/build-and-debug.sh"]
