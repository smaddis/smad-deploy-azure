variable "environment" {
  default = "development"
}

variable "location" {
  default = "West Europe"
}

variable "project_name" {
  default = "smaddis"
}

variable "k8s_agent_count" {
  default = 3
}

# variable "k8s_ssh_public_key" {
#     default = "~/.ssh/id_rsa.pub"
# }

variable "k8s_dns_prefix" {
  default = "k8s"
}

variable "k8s_resource_group_name_suffix" {
  default = "k8s-rg"
}

variable "k8s_cluster_name_suffix" {
  default = "k8s-cluster"
}

variable "log_analytics_workspace_name" {
  default = "LogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable "log_analytics_workspace_location" {
  default = "westeurope"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}

variable "use_separate_storage_rg" {
  default     = true
  type        = bool
  description = "If true, create PVCs created via 'Azure-disk-retain' Storage Class in a separate resource group"
}

variable "enable_log_analytics" {
  type        = bool
  default     = false
  description = "Change value to true to enable log analytics"
}

variable "separate_storage_rg_name" {
  type        = string
  description = "Resource group name for persistent storage outside k8s cluster"
}

variable "storage_share_influx" {
  type        = string
  description = "name of azurerm storage share "
}

variable "storage_share_mongo" {
  type        = string
  description = "name of azurerm storage share "
}

variable "storage_share_kafka" {
  type        = string
  description = "name of azurerm storage share "
}

variable "storage_share_zookeeper" {
  type        = string
  description = "name of azurerm storage share "
}


variable "storage_acc_name" {
  type = string
}

variable "storage_acc_key" {
  type = string
}
