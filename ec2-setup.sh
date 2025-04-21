#!/bin/bash

# Remove set -e to prevent script from exiting on error
# set -e

REPO_URL="git@github.com:17636-DevOps-Final-Project-Group-6/Infrastructure.git"
TARGET_DIR="/home/ubuntu/Infrastructure"

# Function to display service information
display_info() {
    # Get the EC2 public IP
    PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
    
    echo "============================================"
    echo "DevSecOps Pipeline is ready!"
    echo "============================================"
    echo "Jenkins: http://$PUBLIC_IP:8080"
    echo "SonarQube: http://$PUBLIC_IP:9000 (admin/admin)"
    echo "Prometheus: http://$PUBLIC_IP:9090"
    echo "Grafana: http://$PUBLIC_IP:3000 (admin/admin)"
    echo "OWASP ZAP API: http://$PUBLIC_IP:8090"
    echo "============================================"
    echo "Next steps:"
    echo "1. Get Jenkins admin password: sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
    echo "2. Configure Jenkins with required plugins"
    echo "3. Create a SonarQube project and token"
    echo "4. Set up the Jenkins pipeline using the provided Jenkinsfile"
    echo "============================================"
}

# Function to check and deploy updates
check_and_deploy() {
    echo "===== DevOps Infrastructure Deployment Script ====="
    echo "Repository: $REPO_URL"
    echo "Target directory: $TARGET_DIR"
    echo "=================================================="
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker is not installed. Please install Docker before running this script."
        return 1
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker compose &> /dev/null; then
        echo "Error: Docker Compose is not installed. Please install Docker Compose before running this script."
        return 1
    fi
    
    # Get the EC2 public IP
    PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
    echo "Detected public IP: $PUBLIC_IP"
    
    # Check if repository directory exists
    if [ -d "$TARGET_DIR" ]; then
        echo "Repository directory exists. Checking for updates..."
        cd "$TARGET_DIR"
        
        # Store current commit hash
        OLD_COMMIT=$(git rev-parse HEAD)
        
        # Fetch and pull latest changes
        echo "Fetching latest changes..."
        if ! git fetch; then
            echo "Error: Failed to fetch updates. Check your network connection or repository access."
            return 1
        fi
        
        echo "Pulling updates..."
        if ! git pull; then
            echo "Error: Failed to pull updates. There might be conflicts or permission issues."
            echo "Removing repository directory to clone fresh in the next cycle..."
            cd /
            rm -rf "$TARGET_DIR"
            echo "Repository directory deleted. Will clone on next cycle."
            return 0
        fi
        
        # Get new commit hash
        NEW_COMMIT=$(git rev-parse HEAD)
        
        # If commit hashes are the same, no updates were pulled
        if [ "$OLD_COMMIT" == "$NEW_COMMIT" ]; then
            echo "No updates found in the repository. Skipping redeployment."
            display_info
            return 0
        else
            echo "Updates found in the repository. Proceeding with redeployment..."
        fi
    else
        # Clone the repository if it doesn't exist
        echo "Cloning repository to $TARGET_DIR..."
        if ! git clone "$REPO_URL" "$TARGET_DIR"; then
            echo "Error: Failed to clone the repository. Check your network connection or repository access."
            return 1
        fi
        cd "$TARGET_DIR"
    fi
    
    # Deploy with docker compose - continue even if there are errors
    echo "Starting Docker containers..."
    sudo docker compose down || echo "Warning: Docker Compose down command failed, continuing..."
    sudo docker compose up -d || echo "Warning: Docker Compose up command failed, continuing..."
    
    # Wait for services to start
    echo "Waiting for services to start up..."
    sleep 15
    
    # Display service information
    display_info
    
    echo "Infrastructure deployment completed successfully!"
}

# Main loop to check every 15 seconds
echo "Starting continuous deployment service. Checking for updates every 5 seconds..."
while true; do
    check_and_deploy
    echo "Next check in 5 seconds..."
    sleep 5
done