#!/bin/bash

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Update package lists
apt update

# Install required packages
apt install unzip postgresql openjdk-11-jre-headless

# Set a predefined password for the "sonarqube" user
SONARQUBE_PASSWORD="YourPasswordHere"

# Add the "sonarqube" user and set the password non-interactively
useradd -m -p $(openssl passwd -1 "$SONARQUBE_PASSWORD") sonarqube

# Start PostgreSQL service
service postgresql start

# Switch to the "sonarqube" user and continue setting up SonarQube
sudo -u sonarqube bash -c '
  cd ~
  wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.4.0.54424.zip
  unzip sonarqube-9.4.0.54424.zip
  chmod -R 755 ~/sonarqube-9.4.0.54424
  chown -R sonarqube:sonarqube ~/sonarqube-9.4.0.54424
'

# Create the systemd service unit file for SonarQube
cat << EOF | tee /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=simple
User=sonarqube
Group=sonarqube
ExecStart=/home/sonarqube/sonarqube-9.4.0.54424/bin/linux-x86-64/sonar.sh start
ExecStop=/home/sonarqube/sonarqube-9.4.0.54424/bin/linux-x86-64/sonar.sh stop
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Reload the systemd manager configuration to pick up the changes
systemctl daemon-reload

# Enable the SonarQube service to start automatically at boot
systemctl enable sonarqube

# Start the SonarQube service
systemctl start sonarqube

# Check the status of the SonarQube service to ensure it started successfully
systemctl status sonarqube
