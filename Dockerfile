# Use the official Go image as the base image
FROM golang:latest

# Install GitHub CLI
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | apt-key add - && \
    echo "deb [arch=amd64] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install gh

# Set the working directory in the container
WORKDIR /workspace

# Copy the Go source files and the clone script into the container
COPY . .

# Make the clone script and the entrypoint script executable
RUN chmod +x clone.sh 
# Set the entrypoint to the wrapper script

# Default command to run the Go binary
CMD ["go","run","write.go"]
