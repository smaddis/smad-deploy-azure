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
