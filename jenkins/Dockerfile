FROM jenkins/jenkins:lts

USER root

# Install docker-compose
RUN apt-get update && \
    apt-get install -y curl && \
    curl -L "https://github.com/docker/compose/releases/download/v2.24.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Simulink
RUN ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

USER jenkins
