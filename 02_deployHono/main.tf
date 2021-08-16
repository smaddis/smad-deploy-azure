locals {
  project_name    = terraform.workspace == "default" ? var.project_name : "${terraform.workspace}${var.project_name}"
  k8s_agent_count = terraform.workspace == "default" ? var.k8s_agent_count : var.testing_k8s_agent_count
  k8s_dns_prefix  = terraform.workspace == "default" ? var.k8s_dns_prefix : "${terraform.workspace}-${var.k8s_dns_prefix}"
  domain_name     = format("%s.westeurope.cloudapp.azure.com", local.k8s_dns_prefix)
  email           = "email@example.com"
}

data "terraform_remote_state" "storagestate" {
  workspace = terraform.workspace
  backend   = "azurerm"
  config = {
    resource_group_name  = "smaddis-tfstate-rg"
    storage_account_name = "smaddistfstatesa"
    container_name       = "tfstate"
    key                  = "smaddis-storage.tfstate"
  }
}
#module "container_registry_for_k8s" {
#  source                                   = "./modules/container_registry"
#  container_registry_resource_group_suffix = var.container_registry_resource_group_suffix
#  project_name                             = local.project_name
#  k8s_cluster_node_resource_group          = module.k8s.k8s_cluster_node_resource_group
#  k8s_cluster_kubelet_managed_identity_id  = module.k8s.kubelet_object_id
#}


############ MODULES ###########
module "k8s" {
  source                         = "./modules/k8s"
  k8s_agent_count                = local.k8s_agent_count
  k8s_resource_group_name_suffix = var.k8s_resource_group_name_suffix
  project_name                   = local.project_name
  k8s_dns_prefix                 = local.k8s_dns_prefix
  use_separate_storage_rg        = var.use_separate_storage_rg
  separate_storage_rg_name       = data.terraform_remote_state.storagestate.outputs.rg_name
}

module "hono" {
  depends_on       = [module.k8s]
  source           = "./modules/hono"
  mongodb_username = var.mongodb_username
  mongodb_password = var.mongodb_password
}

#TO DO: check if depends_on is needed
module "influxdb" {
  depends_on = [module.k8s]
  source     = "./modules/influxdb"
}

#TO DO: check if depends_on is needed
module "mongodb" {
  depends_on       = [module.k8s]
  source           = "./modules/mongodb"
  mongodb_username = var.mongodb_username
  mongodb_password = var.mongodb_password
}

module "kube_prometheus_stack" {
  depends_on  = [module.k8s]
  source      = "./modules/kube_prometheus_stack"
  domain_name = local.domain_name
}

module "ambassador" {
  depends_on     = [module.k8s]
  source         = "./modules/ambassador"
  k8s_dns_prefix = local.k8s_dns_prefix
}
module "jaeger" {
  depends_on = [module.k8s]
  source     = "./modules/jaeger"
}

###########################################
###########################################
### CRDs for Ambassador and cert-manager ##
###########################################
###########################################
##Hardcoded manifest count value because of https://github.com/gavinbunney/terraform-provider-kubectl/issues/58
## And the -temp resource doesn't work inside modules https://github.com/gavinbunney/terraform-provider-kubectl/issues/61
data "kubectl_path_documents" "ambassador_mappings" {
  pattern = "./ambassador_mappings.yaml"
  vars = {
    domain = local.domain_name
  }
}

resource "kubectl_manifest" "ambassador_manifest" {
  depends_on = [module.hono]
  wait       = true
  count      = length(data.kubectl_path_documents.ambassador_mappings.documents)
  yaml_body  = element(data.kubectl_path_documents.ambassador_mappings.documents, count.index)
}

data "kubectl_path_documents" "tls_mappings" {
  pattern = "./tls_mappings.yaml"
  vars = {
    email  = local.email
    domain = local.domain_name
  }
}

resource "kubectl_manifest" "tls_manifest" {
  depends_on = [module.hono]
  wait       = true
  count      = length(data.kubectl_path_documents.tls_mappings.documents)
  yaml_body  = element(data.kubectl_path_documents.tls_mappings.documents, count.index)
}
#########################
#########################
#########################
#########################

terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.68.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.3.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.11.2"
    }
  }

  backend "azurerm" {
    # Shared state is stored in Azure
    # (https://www.terraform.io/docs/backends/types/azurerm.html)
    #
    # Use './modules/tfstate_storage_azure/main.tf' to create one if needed.
    # See README.md for more details.
    #
    # Authentication is expected to be done via Azure CLI
    # For other authentication means see documentation provided by Microsoft:
    # https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage
    #
    # Set to "${lower(var.project_name)}-${var.tfstate_resource_group_name_suffix}"
    resource_group_name = "smaddis-tfstate-rg"
    # Set to "${lower(var.project_name)}${var.tfstate_storage_account_name_suffix}"
    storage_account_name = "smaddistfstatesa"
    # Set to var.tfstate_container_name
    container_name = "tfstate"
    # Set up "${lower(var.project_name)}.tfstate"
    key = "smaddis.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.k8s.host
  client_key             = base64decode(module.k8s.client_key)
  client_certificate     = base64decode(module.k8s.client_certificate)
  cluster_ca_certificate = base64decode(module.k8s.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.k8s.host
    client_key             = base64decode(module.k8s.client_key)
    client_certificate     = base64decode(module.k8s.client_certificate)
    cluster_ca_certificate = base64decode(module.k8s.cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = module.k8s.host
  client_key             = base64decode(module.k8s.client_key)
  client_certificate     = base64decode(module.k8s.client_certificate)
  cluster_ca_certificate = base64decode(module.k8s.cluster_ca_certificate)
  load_config_file       = false
  apply_retry_count      = 15
}

resource "azurerm_role_assignment" "k8s-storage-role-ass" {
  count                            = var.use_separate_storage_rg ? 1 : 0
  scope                            = data.terraform_remote_state.storagestate.outputs.rg_id
  role_definition_name             = "Owner" # This needs to be changed to a more restrictive role
  principal_id                     = module.k8s.mi_principal_id
  skip_service_principal_aad_check = true
}
