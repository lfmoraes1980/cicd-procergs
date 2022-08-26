terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.19.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "azure-aks" {
  name     = "azure-aks"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "cluster-aks" {
  name                = "aks"
  location            = azurerm_resource_group.azure-aks.location
  resource_group_name = azurerm_resource_group.azure-aks.name
  dns_prefix          = "labs"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_DS2_v2"
    zones = [1,2,3]
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "labsacr25082022"
  resource_group_name = azurerm_resource_group.azure-aks.name
  location            = azurerm_resource_group.azure-aks.location
  sku                 = "Premium"
  admin_enabled       = false

}

resource "azurerm_role_assignment" "acr_role" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.cluster-aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

