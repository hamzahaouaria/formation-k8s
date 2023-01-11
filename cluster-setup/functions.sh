#!/bin/bash

function create_cluster {
  # Init providers
   terraform init

  # Create cluster
   terraform apply

  # Extract admin kube_config
  terraform output kube_config | head -n-1 | tail -n +2 > kube-config.yml
}

function copy_admin_kube_config {
  # Replace local kubeconfig with AKS config
  cp ~/.kube/config ~/.kube/config.bkp
  cp ./kube-config.yml ~/.kube/config

  # Set AKS Cluser as current context
  kubectl config set-context k8s-cluster
}

function create_k8s_roles {
  email=$1
  user="$(echo $email | cut -d@ -f1 | tr . -)"
  namespace="${user}-ns"
  echo "================================================="
  echo "Creating user, namespace and roles for $email"
  echo "User: $user"
  echo "Namespace: $namespace"

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $namespace

---

apiVersion: v1
kind: ServiceAccount
metadata:
  name: $user
  namespace: $namespace
---

apiVersion: v1
kind: Secret
metadata:
  name: $user-token
  namespace: $namespace
  annotations:
    kubernetes.io/service-account.name: $user
type: kubernetes.io/service-account-token

---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: $namespace-full-access
  namespace: $namespace
rules:
- apiGroups: ["", "apps", "batch"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["autoscaling"]
  resources: ["*"]
  verbs: ["list"]

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: $user-role-binding
  namespace: $namespace
subjects:
- kind: ServiceAccount
  name: $user
  namespace: $namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: $namespace-full-access
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: $user-cluster-access
rules:
- apiGroups: [""]
  resources: ["namespaces", "nodes", "persistentvolumes"]
  verbs: ["list"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses"]
  verbs: ["list"]
---

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: $user-cluster-view
subjects:
- kind: ServiceAccount
  name: $user
  namespace: $namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: $user-cluster-access
EOF
}

function create_kube_config {
  server=$1
  namespace=$2
  user=$3
  outputDir=$4

  echo "Creating kubeconfig for user: $user"

  ca=$(kubectl get secret ${user}-token -n $namespace -o jsonpath='{.data.ca\.crt}')
  token=$(kubectl get secret ${user}-token -n $namespace -o jsonpath='{.data.token}' | base64 --decode)
  namespace=$(kubectl get secret ${user}-token -n $namespace -o jsonpath='{.data.namespace}' | base64 --decode)

  echo "
apiVersion: v1
kind: Config
clusters:
- name: default-cluster
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
contexts:
- name: default
  context:
    cluster: default-cluster
    namespace: ${namespace}
    user: default-user
current-context: default
users:
- name: default-user
  user:
    token: ${token}" > $outputDir/$user.kubeconfig

  echo "Kubeconfig generated for user: $user in file $user.kubeconfig"
}

function upload_kube_configs_azure {
  accountName=$(terraform output --raw storage_account_name)
  accountKey=$(terraform output --raw storage_account_key)
  containerName=$(terraform output --raw storage_container_name)

  echo "Uploading kubeconfigs to Azure to Storage Account: $accountName Under container $containerName"

  az storage blob upload-batch --source kubeconfigs --destination $containerName --account-name $accountName --account-key $accountKey --overwrite

  echo "Uploading Admin kubeconfig to Azure to Storage Account: $accountName Under container $containerName/kube-config.yml"
  az storage blob upload --file kube-config.yml --container-name $containerName --name kube-config.yml --account-name $accountName --account-key $accountKey
}