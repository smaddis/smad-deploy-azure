terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.45.1"
    }
  }
}

  provider "azurerm" {
      features {}
  }
# data "azurerm_user_assigned_identity" "aks_kubelet_mi_id" {
#   name                = "${var.k8s_cluster_managed_identity_id}"
#   resource_group_name = "${var.k8s_cluster_node_resource_group}"
# }

resource "azurerm_container_registry" "acr" {
  # alpha numeric characters only are allowed
  name                     = "${lower(var.project_name)}${var.container_registry_name_suffix}"
  resource_group_name      = "${lower(var.project_name)}-${var.container_registry_resource_group_suffix}"
  location                 = var.location
  sku                      = "Standard"
  admin_enabled            = false
}

resource "azurerm_role_assignment" "acrpull_role" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = var.k8s_cluster_kubelet_managed_identity_id
  skip_service_principal_aad_check = true
}
