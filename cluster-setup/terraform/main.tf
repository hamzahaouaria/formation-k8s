terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.38.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  tenant_id       = "f1166c20-6e84-4169-95cd-395fe1212826" # Novencia Tenant
  subscription_id = "ce80d183-bf52-4113-8097-6dad78c8fdb0" # Techlead Subscription
}

# Create a resource group
resource "azurerm_resource_group" "formation-k8s-cluster" {
  name     = "formation-k8s-cluster"
  location = var.location
  tags     = var.tags
}

