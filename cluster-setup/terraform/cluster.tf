resource "azurerm_kubernetes_cluster" "k8s-cluster" {
  name                = "k8s-cluster"
  location            = azurerm_resource_group.formation-k8s-cluster.location
  resource_group_name = azurerm_resource_group.formation-k8s-cluster.name
  dns_prefix          = "k8s-formation"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                  = "default"
    node_count            = var.node_count
    vm_size               = var.vm_size
    enable_auto_scaling   = false
    zones                 = []
    enable_node_public_ip = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.k8s-cluster.kube_config.0.client_certificate

  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.k8s-cluster.kube_config_raw

  sensitive = true
}

output "api_server" {
  value = azurerm_kubernetes_cluster.k8s-cluster.kube_config.0.host

  sensitive = true
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.k8s-cluster.node_resource_group
}
