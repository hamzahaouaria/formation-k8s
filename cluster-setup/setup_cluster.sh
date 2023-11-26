#!/bin/bash
set -e

. ./functions.sh

cd terraform
create_cluster
copy_admin_kube_config

# Get API Server uri
server=$(terraform output api_server)
echo "Server URI: $server"

# Configure a Namespace and a kubeconfig for each user
mkdir -p kubeconfigs
while IFS= read -r email || [[ -n "$email" ]]; do
  user="$(echo $email | cut -d@ -f1 | tr . -)"
  namespace="${user}-ns"
  create_k8s_roles $email
  create_kube_config $server $namespace $user ./kubeconfigs
done <../users.txt

cp ~/.kube/config.bkp ~/.kube/config

upload_kube_configs_and_disk_uris_azure