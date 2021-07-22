variable "environment" {
  type    = string
  default = "development"
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "project_name" {
  type    = string
  default = "smaddis"
}

variable "tfstate_resource_group_name_suffix" {
  type    = string
  default = "tfstate-rg"
}

# 'name' must be unique across the entire Azure service,
#  not just within the resource group.
# 'name' can only consist of lowercase letters and numbers,
#  and must be between 3 and 24 characters long.
variable "tfstate_storage_account_name_suffix" {
  type    = string
  default = "tfstatesa"
}

variable "tfstate_container_name" {
  type    = string
  default = "tfstate"
}
