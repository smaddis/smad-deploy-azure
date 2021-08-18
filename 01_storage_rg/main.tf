terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.68.0"
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
    resource_group_name = "smaddis-tfstate-rg"
    # We can use the same storage account as we use in storing other tfstate files
    storage_account_name = "smaddistfstatesa"
    # We can use the same container as we use in storing other tfstate files
    container_name = "tfstate"
    # Separate state file so we can use it in terraform_remote_state datasource
    key = "smaddis-storage.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "storage_rg" {
  name     = "storage-resource-group-${terraform.workspace}"
  location = var.location
}
resource "azurerm_storage_account" "storage_account" {
  name                     = "storage${terraform.workspace}"
  resource_group_name      = azurerm_resource_group.storage_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "influx_share" {
  name                 = "influx-share${terraform.workspace}"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 10
}

resource "azurerm_storage_share" "mongo_share" {
  name                 = "mongo-share${terraform.workspace}"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 10
}
resource "azurerm_storage_share" "kafka_share" {
  name                 = "kafka-share${terraform.workspace}"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 10
}

resource "azurerm_storage_share" "zookeeper_share" {
  name                 = "zookeeper-share${terraform.workspace}"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 10
}
resource "azurerm_storage_share" "hono_share" {
  name                 = "hono-share${terraform.workspace}"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 10
}
/*
resource "azurerm_managed_disk" "influx" {
  name                 = "influx"
  location             = var.location
  resource_group_name  = "storage-resource-group-${terraform.workspace}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "8"
}
resource "azurerm_managed_disk" "example" {
  name                 = "example"
  location             = var.location
  resource_group_name  = "storage-resource-group-${terraform.workspace}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "8"
}
*/