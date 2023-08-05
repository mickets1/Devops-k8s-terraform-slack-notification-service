#!/bin/bash

# Update all packages
sudo apt update
sudo apt upgrade -y

# Install packages that are required or nice to have
sudo apt-get install -qq apt-transport-https ca-certificates curl software-properties-common jq

# Download and add keys for Docker and k8s
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Add Docker and k8s repos and update
sudo add-apt-repository -yu "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo add-apt-repository -yu "deb https://apt.kubernetes.io/ kubernetes-xenial main"

# Install required packages
sudo apt-get install -qq docker-ce kubelet kubeadm kubectl

# Configure Docker to use systemd
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart and auto start Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
