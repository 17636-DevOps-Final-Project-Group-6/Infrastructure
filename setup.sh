#!/bin/bash

echo "Setting up DevSecOps Pipeline Infrastructure..."

# Create necessary directories
mkdir -p prometheus zap-reports

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker before running this script."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose before running this script."
    exit 1
fi

# Start all services
echo "Starting Docker containers..."
docker-compose up -d

# Wait for services to start
echo "Waiting for services to start up..."
sleep 30

# Display service URLs
echo "============================================"
echo "DevSecOps Pipeline is ready!"
echo "============================================"
echo "Jenkins: http://localhost:8080"
echo "SonarQube: http://localhost:9000 (admin/admin)"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "OWASP ZAP API: http://localhost:8090"
echo "============================================"
echo "Next steps:"
echo "1. Get Jenkins admin password: docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
echo "2. Configure Jenkins with required plugins"
echo "3. Create a SonarQube project and token"
echo "4. Update the Ansible inventory file with your production server details"
echo "5. Fork and clone the spring-petclinic repository"
echo "6. Set up the Jenkins pipeline using the provided Jenkinsfile"
echo "============================================" 