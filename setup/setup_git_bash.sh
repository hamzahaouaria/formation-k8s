#!/bin/bash

user=$1
if [ -z "$user" ]; then
  echo "Usage: setup.sh <firstname-lastname>"
  exit 1
fi

# Download And validate checksum of kubectl
echo "Downloading kubectl..."
curl -LOs "https://dl.k8s.io/release/v1.23.0/bin/windows/amd64/kubectl.exe"
curl -LOs "https://dl.k8s.io/v1.23.0/bin/windows/amd64/kubectl.exe.sha256"
echo "$(cat kubectl.exe.sha256)  kubectl.exe" | sha256sum --check
if [ $? -ne 0 ]; then
  echo "Checksum does not match."
  exit 1
fi
rm kubectl.exe.sha256

# Download Kubeconfig and copy to ~/.kube/config
echo "Downloading kubeconfig..."
curl -O -J https://entredevk8s.blob.core.windows.net/configs/$user.kubeconfig
mkdir -p ~/.kube
mv $user.kubeconfig ~/.kube/config

# Show nodes
kubectl.exe get nodes