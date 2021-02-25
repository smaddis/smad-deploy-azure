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

# NOTE: Needed when storage account uniqueness wants to be automatically achieved
# resource "random_string" "storage_account_name_suffix" {
#     length  = 8
#     upper   = false
#     number  = true
#     lower   = true
#     special = false
# }

resource "azurerm_resource_group" "tfstate_rg" {
    name     = "${lower(var.project_name)}-${var.tfstate_resource_group_name_suffix}"
    location = var.location
    # lifecycle {
    #     prevent_destroy = true
    # }
    tags = {
        environment = var.environment
    }
}

resource "azurerm_storage_account" "tfstate_sa" {
    depends_on = [azurerm_resource_group.tfstate_rg]

    # 'name' must be unique across the entire Azure service, not just within the resource group.
    # 'name' can only consist of lowercase letters and numbers, and must be between 3 and 24 characters long
    # NOTE: Uncomment the next line to generate suffix for storage account.
    # name                     = "${substr(lower(var.project_name), 0, 4)}tfstatesa${random_id.storage_account_name_suffix.result}"
    name                     = "${lower(var.project_name)}${var.tfstate_storage_account_name_suffix}"
    resource_group_name      = azurerm_resource_group.tfstate_rg.name
    location                 = var.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
  
    # lifecycle {
    #     prevent_destroy = true
    # }
    tags = {
        environment = var.environment
    }
}

resource "azurerm_storage_container" "tfstate_container" {
    depends_on            = [azurerm_storage_account.tfstate_sa]
    name                  = var.tfstate_container_name
    storage_account_name  = azurerm_storage_account.tfstate_sa.name
    container_access_type = "private"

    # lifecycle {
    #     prevent_destroy = true
    # }
}
