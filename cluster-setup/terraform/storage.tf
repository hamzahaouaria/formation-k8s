resource "azurerm_storage_account" "entre-dev-k8s" {
  name                            = "entredevk8s"
  resource_group_name             = azurerm_resource_group.k8s-cluster-entre-dev.name
  location                        = azurerm_resource_group.k8s-cluster-entre-dev.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true

  tags = var.tags
}

resource "azurerm_storage_container" "configs" {
  name                  = "configs"
  storage_account_name  = azurerm_storage_account.entre-dev-k8s.name
  container_access_type = "blob"
}


output "storage_account_name" {
  value = azurerm_storage_account.entre-dev-k8s.name
}

output "storage_account_key" {
  value = azurerm_storage_account.entre-dev-k8s.primary_access_key

  sensitive = true
}

output "storage_container_name" {
  value = azurerm_storage_container.configs.name
}
