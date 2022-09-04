#!/bin/bash

user=$1
if [ -z "$user" ]; then
  echo "Usage: setup.sh <firstname-lastname>"
  exit 1
fi

# Download And validate checksum of kubectl
echo "Downloading kubectl..."
curl -LOs "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LOs "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
if [ $? -ne 0 ]; then
  echo "Checksum does not match."
  exit 1
fi
rm kubectl.sha256

# Download Kubeconfig and copy to ~/.kube/config
echo "Downloading kubeconfig..."
wget -q https://entredevk8s.blob.core.windows.net/configs/$user.kubeconfig
mkdir -p ~/.kube
mv $user.kubeconfig ~/.kube/config

# Show nodes
chmod +x kubectl
kubectl get nodes