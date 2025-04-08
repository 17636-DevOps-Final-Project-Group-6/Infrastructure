# DevSecOps Pipeline Infrastructure

This directory contains the infrastructure setup for a complete DevSecOps pipeline for the spring-petclinic project.

## Components

- **Jenkins**: Continuous Integration and Continuous Delivery server
- **SonarQube**: Static code analysis
- **Prometheus**: Monitoring system and time series database
- **Grafana**: Analytics and monitoring platform
- **OWASP ZAP**: Security testing tool

## Setup Instructions

### Prerequisites

- Docker and Docker Compose installed
- Git installed
- At least 8GB of RAM available for Docker

### Getting Started

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd Infrastructure
   ```

2. Start all services using Docker Compose:
   ```bash
   docker-compose up -d
   ```

3. Access the services at:
   - Jenkins: http://localhost:8080
   - SonarQube: http://localhost:9000 (default credentials: admin/admin)
   - Prometheus: http://localhost:9090
   - Grafana: http://localhost:3000 (default credentials: admin/admin)
   - OWASP ZAP API: http://localhost:8090

### Initial Configuration

#### Jenkins

1. Get the initial admin password:
   ```bash
   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```
2. Navigate to http://localhost:8080 and follow the setup wizard
3. Install suggested plugins plus:
   - BlueOcean
   - SonarQube Scanner
   - Prometheus metrics
   - Ansible

#### SonarQube

1. Navigate to http://localhost:9000
2. Login with default credentials (admin/admin)
3. Create a new project for spring-petclinic
4. Generate a token for Jenkins integration

#### Grafana

1. Navigate to http://localhost:3000
2. Login with default credentials (admin/admin)
3. Add Prometheus as a data source:
   - Name: Prometheus
   - URL: http://prometheus:9090
4. Import dashboards for Jenkins monitoring

## Network Configuration

All services are connected to a custom Docker network called `devops-network` to enable communication between containers.

## Volume Configuration

Persistent volumes are used for:
- Jenkins home directory
- SonarQube data, logs, and extensions
- PostgreSQL database for SonarQube
- Prometheus data
- Grafana data

## Next Steps

After setting up the infrastructure, you need to:
1. Fork the spring-petclinic project on GitHub
2. Configure Jenkins pipeline using the Jenkinsfile
3. Set up the production VM for deployment
4. Configure Ansible for automated deployment