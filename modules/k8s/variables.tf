variable "environment" {
    default = "development"
}

variable "location" {
    default = "West Europe"
}

variable "project_name" {
    default = "rbackuksatrng"
}

variable "k8s_agent_count" {
    default = 3
}

# variable "k8s_ssh_public_key" {
#     default = "~/.ssh/id_rsa.pub"
# }

variable "k8s_dns_prefix" {
    default = "k8stest"
}

variable "k8s_resource_group_name_suffix" {
    default = "k8stest-rg"
}

variable "k8s_cluster_name_suffix" {
    default = "k8stest-cluster"
}

variable "log_analytics_workspace_name" {
    default = "testLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable "log_analytics_workspace_location" {
    default = "westeurope"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable "log_analytics_workspace_sku" {
    default = "PerGB2018"
}
