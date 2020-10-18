provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you are using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

# Needed to obtain identity (defined in terraform provider configuration)
# running the `terraform apply`.
data "azurerm_client_config" "current" {}

# Create a resource group for security
resource "azurerm_resource_group" "vault_rg" {
    name     = "${lower(var.project_name)}-vault-rg"
    location = var.location
}

# Create the Azure Key Vault
resource "azurerm_key_vault" "key_vault" {
    name                = "${lower(var.project_name)}-keyvault"
    location            = var.location
    resource_group_name = azurerm_resource_group.vault_rg.name
  
    # enabled_for_deployment          = var.enabled_for_deployment
    # enabled_for_disk_encryption     = var.enabled_for_disk_encryption
    # enabled_for_template_deployment = var.enabled_for_template_deployment

    # Ownership is given to identity (defined in terraform provider configuration)
    # running the `terraform apply`.
    tenant_id = data.azurerm_client_config.current.tenant_id

    sku_name  = var.sku_name
    
    tags = {
        environment = var.environment
    }

    # TODO: Check if default_action = "Deny" works
    network_acls {
        default_action = "Allow"
        bypass         = "AzureServices"
    }
}

# Create a Default Azure Key Vault access policy with Admin permissions
# This policy must be kept for a proper run of the "destroy" process
resource "azurerm_key_vault_access_policy" "default_policy" {
    key_vault_id = azurerm_key_vault.key_vault.id

    # Full access is given to identity (defined in terraform provider configuration)
    # running the `terraform apply`.
    # TODO: Extract this to variables.tf and do 
    #       the 'data "azurerm_client_config" "current" {}'
    #       in calling main.tf?
    #       This reduces portability and independece of the module quite much.
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = data.azurerm_client_config.current.object_id

    lifecycle {
        create_before_destroy = true
    }

    key_permissions = var.kv-key-permissions-full
    secret_permissions = var.kv-secret-permissions-full
    certificate_permissions = var.kv-certificate-permissions-full
    storage_permissions = var.kv-storage-permissions-full
}

# Create Azure Key Vault access policies (note the 'for_each' directive).
# You define these in main.tf calling this module.
# See variables.tf for documentation and usage example.
resource "azurerm_key_vault_access_policy" "policy" {
  for_each                = var.policies
  key_vault_id            = azurerm_key_vault.key_vault.id
  tenant_id               = lookup(each.value, "tenant_id")
  object_id               = lookup(each.value, "object_id")
  key_permissions         = lookup(each.value, "key_permissions")
  secret_permissions      = lookup(each.value, "secret_permissions")
  certificate_permissions = lookup(each.value, "certificate_permissions")
  storage_permissions     = lookup(each.value, "storage_permissions")
}

