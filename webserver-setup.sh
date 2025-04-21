# This script sets up a web server on an Ubuntu instance and deploys the Spring PetClinic application.
sudo vi /etc/systemd/system/petclinic.service
# Copy the following into the file above
# [Unit]
# Description=Spring PetClinic Application
# After=network.target

# [Service]
# User=ubuntu
# WorkingDirectory=/home/ubuntu/app
# ExecStart=/usr/bin/java -jar /home/ubuntu/app/spring-petclinic-3.4.0-SNAPSHOT.jar
# Restart=always

# [Install]
# WantedBy=multi-user.target

# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable petclinic
sudo systemctl start petclinic

# Verify status
sudo systemctl status petclinic

# Stop webserver: sudo systemctl stop petclinic.service
