#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&


# Set up the stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index (again)
sudo apt-get update -y &&

# Install the latest version of Docker Engine and containerd
sudo apt-get install -y docker-ce docker-ce-cli containerd.io &&

# Add the ubuntu user to the docker group
sudo usermod -aG docker ubuntu

# Enable Docker to start on boot
sudo systemctl enable docker

# Start Docker
sudo systemctl start docker

# Print Docker version (for verification)
docker --version