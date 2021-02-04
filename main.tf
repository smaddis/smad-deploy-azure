

# module "tfstate_storage_azure" {
#     source  = "./modules/tfstate_storage_azure"
#
#     location = "West Europe"
#     project_name = "kuksatrng"
#     environment = "development"
#     tfstate_storage_account_name_suffix = "tfstatesa"
# }

module "k8s_cluster_azure" {
    source = "./modules/k8s"
    k8s_agent_count = var.k8s_agent_count
    k8s_resource_group_name_suffix = var.k8s_resource_group_name_suffix
    project_name = var.project_name
}

module "container_registry_for_k8s" {
    source = "./modules/container_registry"
    container_registry_resource_group_suffix = var.container_registry_resource_group_suffix
    project_name = var.project_name
    k8s_cluster_node_resource_group = module.k8s_cluster_azure.k8s_cluster_node_resource_group
    k8s_cluster_kubelet_managed_identity_id = module.k8s_cluster_azure.kubelet_object_id
}

terraform {

      required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 2.45.1"
        }
    }

    backend "azurerm" {
        # Shared state is stored in Azure
        # (https://www.terraform.io/docs/backends/types/azurerm.html)
        #
        # Use './modules/tfstate_storage_azure/main.tf' to create one if needed.
        # See README.md for more details.
        #
        # Authentication is expected to be done via Azure CLI
        # For other authentication means see documentation provided by Microsoft:
        # https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage
        #
        # Set to "${lower(var.project_name)}-${var.tfstate_resource_group_name_suffix}"
        resource_group_name  = "kuksatrng-tfstate-rg"
        # Set to "${lower(var.project_name)}${var.tfstate_storage_account_name_suffix}"
        storage_account_name = "kuksatrngtfstatesa"
        # Set to var.tfstate_container_name
        container_name       = "tfstate"
        # Set up "${lower(var.project_name)}.tfstate"
        key                  = "kuksatrng.tfstate"
    }
}
 provider "azurerm" {
      features {}
  }
