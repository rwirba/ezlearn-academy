#!/bin/bash

# Update and install necessary packages
sudo apt-get update -y
sudo apt-get install -y wget curl git

# Install Java (OpenJDK 17)
sudo apt-get install -y openjdk-17-jdk

# Set JAVA_HOME environment variable
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /etc/profile
echo "export PATH=\$JAVA_HOME/bin:\$PATH" | sudo tee -a /etc/profile
source /etc/profile

# Verify Java installation
java -version

# Install Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Download and install Maven in /opt/maven
cd /tmp
wget https://dlcdn.apache.org/maven/maven-3/3.9.8/binaries/apache-maven-3.9.8-bin.tar.gz
sudo mkdir -p /opt/maven
sudo tar xzvf apache-maven-3.9.8-bin.tar.gz -C /opt/maven --strip-components=1

# Set M2_HOME and update PATH environment variable
echo "export M2_HOME=/opt/maven" | sudo tee -a /etc/profile
echo "export PATH=\$M2_HOME/bin:\$PATH" | sudo tee -a /etc/profile
source /etc/profile

# Verify Maven installation
mvn -version

# Install Tomcat 9
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.1/bin/apache-tomcat-9.0.1.tar.gz
sudo mkdir -p /opt/tomcat9
sudo tar xzvf apache-tomcat-9.0.1.tar.gz -C /opt/tomcat9 --strip-components=1
sudo chown -R ubuntu:ubuntu /opt/tomcat9

# Set up Tomcat as a systemd service
cat <<EOF | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment="JAVA_HOME=$JAVA_HOME"
Environment="CATALINA_PID=/opt/tomcat9/temp/tomcat.pid"
Environment="CATALINA_HOME=/opt/tomcat9"
Environment="CATALINA_BASE=/opt/tomcat9"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

ExecStart=/opt/tomcat9/bin/startup.sh
ExecStop=/opt/tomcat9/bin/shutdown.sh

User=ubuntu
Group=ubuntu
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to apply the new service
sudo systemctl daemon-reload
sudo systemctl enable tomcat

# Change the default Tomcat port from 8080 to 8081
sudo sed -i 's/port="8080"/port="8081"/' /opt/tomcat9/conf/server.xml

# Start Tomcat service
sudo systemctl start tomcat

# Open port 8081 in the firewall
sudo ufw allow 8081/tcp

# Output installation details
echo "Jenkins, Maven, and Tomcat 9 installation complete."
echo "Jenkins is running on port 8080."
echo "Tomcat 9 is running on port 8081."

