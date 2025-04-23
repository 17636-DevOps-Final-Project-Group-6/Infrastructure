# Start from the official Jenkins LTS image
FROM jenkins/jenkins:lts

USER root

# Install jq and other useful tools
RUN apt-get update && \
    apt-get install -y jq curl git && \
    apt-get clean

RUN chown -R jenkins:jenkins /var/jenkins_home

USER jenkins
