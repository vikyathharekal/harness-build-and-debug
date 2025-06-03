FROM golang:1.20-alpine

RUN apk add --no-cache curl bash git

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s latest \
 && mv ./bin/golangci-lint /usr/local/bin/ \
 && /usr/local/bin/golangci-lint --version

# Copy your script into the image
COPY build-and-debug.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/build-and-debug.sh

WORKDIR /harness

ENTRYPOINT ["/usr/local/bin/build-and-debug.sh"]

