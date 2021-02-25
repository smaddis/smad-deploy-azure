provider "helm" {
    kubernetes {
        config_path = "~/.kube/config" # Replace if you have different kubeconfig path!
        config_context = "rbackuksatrng-k8stest-cluster-admin" # Replace with your admin context name!
        # host                   = var.k8s_host
        # username               = var.k8s_username
        # password               = var.k8s_password
        client_certificate     = base64decode(var.k8s_client_cert)
        client_key             = base64decode(var.k8s_client_key)
        cluster_ca_certificate = base64decode(var.k8s_cluster_ca_cert)
    }
}


resource "helm_release" "kv_azure_csi" {
    name             = "csi-secrets-provider-azure"
    repository       = var.repository
    chart            = "csi-secrets-store-provider-azure"
    version          = var.csi_provider_version
    # In which K8S namespace the Azure provider for CSI driver should be installed.
    # TODO: Should this be the same namespace as where the actual application is deployed.
    namespace        = var.namespace
    create_namespace = true
}
