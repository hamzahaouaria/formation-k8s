#!/bin/bash

function create_cluster {
  # Init providers
  terraform init

  # Create cluster
  terraform apply -var="users=[$(cat ../users.txt | cut -d@ -f1 | tr . - | sed 's/.*/"&"/' | paste -sd,)]"

  # Extract admin kube_config
  terraform output kube_config | head -n-1 | tail -n +2 > kube-config.yml
}

function copy_admin_kube_config {
  # Replace local kubeconfig with AKS config
  cp ~/.kube/config ~/.kube/config.bkp
  cp ./kube-config.yml ~/.kube/config

  # Set AKS Cluster as current context
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

function upload_kube_configs_and_disk_uris_azure {
  accountName=$(terraform output --raw storage_account_name)
  accountKey=$(terraform output --raw storage_account_key)
  containerName=$(terraform output --raw storage_container_name)

  echo "Uploading kubeconfigs to Azure to Storage Account: $accountName Under container $containerName"
  az storage blob upload-batch --source kubeconfigs --destination $containerName --account-name $accountName --account-key $accountKey --overwrite

  echo "Uploading Admin kubeconfig to Azure to Storage Account: $accountName Under container $containerName/kube-config.yml"
  az storage blob upload --file kube-config.yml --container-name $containerName --name kube-config.yml --account-name $accountName --account-key $accountKey

  generate_disk_uri_files
  echo "Uploading Disk URI files to Azure to Storage Account: $accountName Under container $containerName"
  az storage blob upload-batch --source disk-uris --destination $containerName --account-name $accountName --account-key $accountKey --overwrite
}

# Extract the disk uris generated in terraform and dump them into files
# Each file will contain the uri of disk of a single user
function generate_disk_uri_files {
  diskIds=$(terraform output disk_id | head -n-1 | tail -n +2 | tr -d '"' | tr -d ',')
  mkdir -p disk-uris
  for path in $diskIds; do
      # Extract the name
      diskName=$(echo $path | cut -d/ -f9)
      name=$(echo ${diskName#"formationk8sdisk-"})

      # Write the path to a new file named "disk-uri-NAME"
      echo $path > "disk-uris/disk-uri-$name"
  done
}

function create_persistent_volume_per_user {
  for diskUriFile in $(ls disk-uris); do
    diskUri=$(cat "disk-uris/$diskUriFile")
    userName=$(echo ${diskUriFile#"disk-uri-"})
    volumeName=$(echo $diskUri | cut -d/ -f9)
    cat <<EOF | kubectl --kubeconfig=kube-config.yml apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: $volumeName
spec:
  capacity:
    storage: 1Gi # Capacité du volume
  accessModes: # Mode d'accès
    - ReadWriteOnce
  azureDisk: # Définition du Azure Disk distant
    kind: Managed
    diskName: $volumeName
    diskURI: $diskUri
EOF
  done
}