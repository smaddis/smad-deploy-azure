output "kube_config" {
    value = module.k8s_cluster_azure.kube_config
    description = "A 'kube_config' object to be used with kubectl and Helm"
    sensitive   = true
}

output "cr_login_url" {
    value = module.container_registry_for_k8s.cr_login_url
    description = "URL that can be used to log into the container registry."
    sensitive   = false
}

output "mi_principal_id" {
    value = module.k8s_cluster_azure.mi_principal_id
    sensitive   = false
}

output "mi_tenant_id" {
    value = module.k8s_cluster_azure.mi_tenant_id
    sensitive   = false
}

output "kubelet_client_id" {
    value = module.k8s_cluster_azure.kubelet_client_id
    sensitive   = false
}

output "kubelet_object_id" {
    value = module.k8s_cluster_azure.kubelet_object_id
    sensitive   = false
}


output "key_vault_id" {
    value       = module.keyvault_for_secrets.key_vault_id
    description = "Key Vault ID"
    sensitive   = false
}

output "key_vault_name" {
    value       = module.keyvault_for_secrets.key_vault_name
    description = "Name of Key Vault"
    sensitive   = false
}

output "key_vault_tenant_id" {
    value       = module.keyvault_for_secrets.key_vault_tenant_id
    description = "Tenant ID of the tenant under which Key Vault was created."
    sensitive   = false
}
