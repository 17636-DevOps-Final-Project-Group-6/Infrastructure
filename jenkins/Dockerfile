# Use the official Jenkins LTS image as the base image
FROM jenkins/jenkins:lts

# Switch to root user to install packages
USER root

# Install Docker dependencies
RUN apt-get update && \
    apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    sudo \
    unzip

# Add Docker's official GPG key
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/trusted.gpg.d/docker.asc

# Set up Docker stable repository
RUN echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
RUN apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Ensure Docker socket is available for Jenkins to interact with Docker on the host
VOLUME /var/run/docker.sock:/var/run/docker.sock

# Switch back to the Jenkins user
USER jenkins

# Expose necessary ports for Jenkins
EXPOSE 8080 50000
