FROM alpine/git

# Copy the build-and-debug script into the container
COPY build-and-debug.sh /usr/local/bin/build-and-debug.sh

# Make the script executable
RUN chmod +x /usr/local/bin/build-and-debug.sh

# Set the script as the entrypoint
ENTRYPOINT ["/usr/local/bin/build-and-debug.sh"]
