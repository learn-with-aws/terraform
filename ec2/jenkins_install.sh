#!/bin/bash
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk-devel zip unzip
sudo yum install -y jenkins
# Start jenkins service
sudo systemctl start jenkins
# Setup Jenkins to start at boot,
sudo systemctl enable jenkins