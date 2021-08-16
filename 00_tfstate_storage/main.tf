terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.68.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tfstate_rg" {
  name     = "${lower(var.project_name)}-${var.tfstate_resource_group_name_suffix}"
  location = var.location
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    environment = var.environment
  }
}

resource "azurerm_storage_account" "tfstate_sa" {
  name                     = "${lower(var.project_name)}${var.tfstate_storage_account_name_suffix}"
  resource_group_name      = azurerm_resource_group.tfstate_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    prevent_destroy = true
  }
  tags = {
    environment = var.environment
  }
}

resource "azurerm_storage_container" "tfstate_container" {
  name                  = var.tfstate_container_name
  storage_account_name  = azurerm_storage_account.tfstate_sa.name
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}
