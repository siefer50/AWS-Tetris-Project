# !/bin/bash
# For Ubuntu 22.04
# Intsalling Java
set -e
 
# Update system and install core packages for the CI server being hosted through Jenkins
# Jenkins installation. All the software listed below will be installed on the jenkins server
 
echo "=== Updating system ==="
sudo apt update -y
sudo apt upgrade -y
 
echo "=== Installing Java 21 (required by Jenkins 2.463+) ==="
sudo apt install -y openjdk-21-jre
 
echo "=== Removing old Jenkins repo and key if present ==="
sudo rm -f /etc/apt/sources.list.d/jenkins.list
sudo rm -f /usr/share/keyrings/jenkins-keyring.gpg
 
echo "=== Importing Jenkins signing key (old key required for current repo) ==="
sudo gpg --keyserver keyserver.ubuntu.com --recv-keys 7198F4B714ABFC68
sudo gpg --export 7198F4B714ABFC68 | sudo tee /usr/share/keyrings/jenkins-keyring.gpg > /dev/null
 
echo "=== Adding Jenkins repository ==="
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
 
echo "=== Updating apt with Jenkins repo ==="
sudo apt update -y
 
echo "=== Installing Jenkins ==="
sudo apt install -y jenkins
 
echo "=== Enabling and starting Jenkins service ==="
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins
 
# Installing Docker
sudo apt update
sudo apt install docker.io -y
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo systemctl restart docker
sudo chmod 777 /var/run/docker.sock
 
# If you don't want to install Jenkins, you can create a container of Jenkins
# docker run -d -p 8080:8080 -p 50000:50000 --name jenkins-container jenkins/jenkins:lts
 
# Run Docker Container of Sonarqube
docker run -d --name sonarqube -p 9000:9000 sonarqube:community
 
 
# Installing Terraform
sudo apt install unzip -y
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform -y
 
# Installing Kubectl
curl -LO https://dl.k8s.io/release/v1.33.5/bin/linux/amd64/kubectl
curl -LO https://dl.k8s.io/release/v1.33.5/bin/linux/amd64/kubectl.sha256
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
 
# Installing AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
 
# Installing Trivy
sudo apt-get install wget gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
trivy --version