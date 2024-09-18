# Use the official Alpine image as the base image
FROM alpine:latest

# Install dependencies and Go
RUN apk update && \
    apk add --no-cache \
    curl \
    git \
    make \
    go \
    bash

# Install GitHub CLI
RUN apk update && \
    apk add github-cli glab

# Set the working directory in the container
WORKDIR /workspace

# Copy the Go source files and the clone script into the container
COPY . .

# Make the clone script and the entrypoint script executable
RUN chmod +x clone.sh 
# Set the entrypoint to the wrapper script

# Default command to run the Go binary
CMD ["go","run","write.go"]
