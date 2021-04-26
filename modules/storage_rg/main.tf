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
    # This creates separate tfstate for a resource group for storage needs.
    # This way we can have storage volumes that will not be destroyed every time we run `terraform destroy`
    #
    # Authentication is expected to be done via Azure CLI
    # For other authentication means see documentation provided by Microsoft:
    # https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage
    #
    # We can use the same resource group as we use in storing other tfstate files
    resource_group_name = "kuksatrng-tfstate-rg"
    # We can use the same storage account as we use in storing other tfstate files
    storage_account_name = "kuksatrngtfstatesa"
    # We can use the same container as we use in storing other tfstate files
    container_name = "tfstate"
    # Separate state file so we can use it in terraform_remote_state datasource
    key = "kuksatrng-storage.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "storage_rg" {
  name     = "storage-resource-group"
  location = "West Europe"
}