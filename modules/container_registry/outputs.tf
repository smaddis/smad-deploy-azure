
# ID of the Container Registry
output "cr_id" {
    value = azurerm_container_registry.acr.id
}

# The URL that can be used to log into the container registry.
output "cr_login_url" {
    value = azurerm_container_registry.acr.login_server
}

# The Username associated with the Container Registry Admin account 
# - if the admin account is enabled.
output "cr_admin_username" {
    value = azurerm_container_registry.acr.admin_username
}

# The Password associated with the Container Registry Admin account 
# - if the admin account is enabled.
output "cr_admin_password" {
    value = azurerm_container_registry.acr.admin_password
    sensitive = true
}
