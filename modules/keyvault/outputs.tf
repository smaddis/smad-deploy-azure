output "key_vault_id" {
    description = "Key Vault ID"
    value       = azurerm_key_vault.key_vault.id
}

output "key_vault_url" {
    description = "Key Vault URI"
    value       = azurerm_key_vault.key_vault.vault_uri
}

output "key_vault_name" {
    description = "Name of Key Vault"
    value       = azurerm_key_vault.key_vault.name
}

output "key_vault_tenant_id" {
    description = "Tenant ID of the tenant under which Key Vault was created."
    value       = azurerm_key_vault.key_vault.tenant_id
}

