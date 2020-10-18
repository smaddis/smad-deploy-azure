variable "environment" {
    default = "development"
}

variable "location" {
    default = "West Europe"
}

variable "project_name" {
    default = "kuksatrng"
}

# See secrets-store-csi-driver-provider-azure documentation, e.g. for version information.
# https://github.com/Azure/secrets-store-csi-driver-provider-azure/blob/master/charts/csi-secrets-store-provider-azure/README.md
variable "csi_provider_version" {
    default = "0.0.13"
}

# Repository where Helm charts for 'csi-secrets-provider-azure' are hosted.
# Note: 'master'-branch is used since helm_release will parse 'index.yaml' located in repo.
#       Despite the 'master' -branch, 'index.yaml' contains only stable version releases.
variable "repository" {
    default = "https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts"
}

# Kubernetes connection details for Helm
# Note: certs and key will be decoded from base64 in modules main.tf.
#       Don't decode them manually.
#       Supply raw values provided by e.g.
#       'azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate'
#       'azurerm_kubernetes_cluster.aks.kube_config.0.client_key'
#       'azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate'
variable "k8s_host" {}
variable "k8s_username" {}
variable "k8s_password" {}
variable "k8s_client_cert" {}
variable "k8s_client_key" {}
variable "k8s_cluster_ca_cert" {}

# In which K8S namespace the Azure provider for CSI driver should be installed.
# TODO: Should this be the same namespace as where the actual application is deployed.
variable "namespace" {
    default = "kuksacloud"
}