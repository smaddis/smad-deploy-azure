variable "environment" {
    default = "development"
}

variable "location" {
    default = "West Europe"
}

variable "project_name" {
    default = "rbackuksatrng"
}

# You can use the same resource group that was used with K8S cluster in AKS
variable "container_registry_resource_group_suffix" {
    default = "k8stest-rg"
}

# alpha numeric characters only are allowed
variable "container_registry_name_suffix" {
    default = "k8stestcr"
}

# Get this from 
# azurerm_kubernetes_cluster.aks.node_resource_group .
# Note the 'aks'. Change it to whatever you use.
variable "k8s_cluster_node_resource_group" {
    default = ""
}

# You can use 
# "${azurerm_kubernetes_cluster.aks.name}-agentpool"
# which should take into account naming convention used in ./modules/k8s/main.tf
# or use
# azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id .
# Note the 'aks'. Change it to whatever you use.
variable "k8s_cluster_kubelet_managed_identity_id" {
    default = ""
}

