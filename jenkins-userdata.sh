#!/bin/bash

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Update package lists
apt update -y

# Install OpenJDK 11
apt install openjdk-11-jre -y

# Add Jenkins GPG key and repository
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package lists again
apt-get update -y

# Install Jenkins
apt-get install jenkins -y

# Get Jenkins initial admin password
until [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; do
  sleep 5
done

JENKINS_INITIAL_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

# Create Jenkins user
JENKINS_USER="your_jenkins_user"
JENKINS_PASSWORD="your_jenkins_password"

sudo useradd -m -s /bin/bash $JENKINS_USER

# Set Jenkins user password
echo "$JENKINS_USER:$JENKINS_PASSWORD" | sudo chpasswd

# Print the Jenkins initial admin password and Jenkins user details
echo "Jenkins Initial Admin Password: $JENKINS_INITIAL_PASSWORD"
echo "Jenkins User: $JENKINS_USER"
echo "Jenkins Password: $JENKINS_PASSWORD"
