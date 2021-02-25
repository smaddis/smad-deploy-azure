variable "environment" {
    default = "development"
}

variable "location" {
    default = "West Europe"
}

variable "project_name" {
    default = "rbackuksatrng"
}

variable "tfstate_resource_group_name_suffix" {
    default = "tfstate-rg"
}

# 'name' must be unique across the entire Azure service, 
#  not just within the resource group.
# 'name' can only consist of lowercase letters and numbers, 
#  and must be between 3 and 24 characters long.
variable "tfstate_storage_account_name_suffix" {
    default = "tfstatesa"
}

variable "tfstate_container_name" {
    default = "tfstate"
}

