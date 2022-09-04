
$User = $args[0]

if ($null -eq $User) {
  Write-Error "Usage: setup.ps1 <firstname-lastname>"
  Exit 1
}

# Download And validate checksum of kubectl
Write-Output "Downloading kubectl..."
$ProgressPreference = 'SilentlyContinue'; 
Invoke-WebRequest https://dl.k8s.io/release/v1.23.0/bin/windows/amd64/kubectl.exe -OutFile kubectl.exe
Invoke-WebRequest https://dl.k8s.io/v1.23.0/bin/windows/amd64/kubectl.exe.sha256 -OutFile kubectl.exe.sha256
CertUtil -hashfile kubectl.exe SHA256
$ChecksumResult = $($(CertUtil -hashfile .\kubectl.exe SHA256)[1] -replace " ", "") -eq $(type .\kubectl.exe.sha256)
if (!$ChecksumResult) {
  Write-Error "Checksum does not match."
  Exit 1
}

# Download Kubeconfig and copy to ~/.kube/config
Write-Output "Downloading kubeconfig..."
Invoke-WebRequest "https://entredevk8s.blob.core.windows.net/configs/$User.kubeconfig" -OutFile "$User.kubeconfig"
New-Item -ItemType Directory -Force -Path ~/.kube
Move-Item -Force -Path "$User.kubeconfig" -Destination ~/.kube/config *>&1

# Show nodes
kubectl.exe get nodes