# Create an azure disk per user
resource "azurerm_managed_disk" "formation-k8s-disk" {
  count = length(var.users)
  name     = "formationk8sdisk-${var.users[count.index]}"
  location = var.location
  # Need to use node resource group not aks resource group
  # Another resource group is created one for infra resources (net, nodes, ...) and another for aks service
  # https://docs.microsoft.com/en-us/azure/aks/faq#why-are-two-resource-groups-created-with-aks
  resource_group_name  = azurerm_kubernetes_cluster.k8s-cluster.node_resource_group # https://stackoverflow.com/questions/62614458/permissions-error-when-attaching-azure-disk-to-aks-pod
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = var.tags
}

output "disk_id" {
  value = azurerm_managed_disk.formation-k8s-disk[*].id
}
