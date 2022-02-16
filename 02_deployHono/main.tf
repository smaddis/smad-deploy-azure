locals {
  project_name    = terraform.workspace == "default" ? var.project_name : "${terraform.workspace}${var.project_name}"
  k8s_agent_count = terraform.workspace == "default" ? var.k8s_agent_count : var.testing_k8s_agent_count
  k8s_dns_prefix  = terraform.workspace == "default" ? var.k8s_dns_prefix : "${terraform.workspace}-${var.k8s_dns_prefix}"
  domain_name     = format("%s.westeurope.cloudapp.azure.com", local.k8s_dns_prefix)
  email           = "lunden.niina@gmail.com"
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
}

module "persistent_storage" {
  depends_on               = [module.k8s]
  source                   = "./modules/persistent_storage"
  separate_storage_rg_name = data.terraform_remote_state.storagestate.outputs.rg_name
  storage_share_influx     = data.terraform_remote_state.storagestate.outputs.storage_share_influx
  storage_share_mongo      = data.terraform_remote_state.storagestate.outputs.storage_share_mongo
  storage_share_dr         = data.terraform_remote_state.storagestate.outputs.storage_share_dr
  storage_share_kafka      = data.terraform_remote_state.storagestate.outputs.storage_share_kafka
  storage_share_zookeeper  = data.terraform_remote_state.storagestate.outputs.storage_share_zookeeper
  storage_acc_name         = data.terraform_remote_state.storagestate.outputs.storage_acc_name
  storage_acc_key          = data.terraform_remote_state.storagestate.outputs.storage_acc_key
}

module "kafka" {
  depends_on = [module.persistent_storage, module.mongo_telemetry]
  source     = "./modules/kafka"
}

module "hono" {
  depends_on = [module.persistent_storage, module.kafka]
  source     = "./modules/hono"
}

module "influxdb" {
  depends_on = [module.persistent_storage]
  source     = "./modules/influxdb"
}

module "mongo_telemetry" {
  depends_on = [module.persistent_storage]
  source     = "./modules/mongo_telemetry"
}

module "kube_prometheus_stack" {
  depends_on  = [module.hono]
  source      = "./modules/kube_prometheus_stack"
  domain_name = local.domain_name
}

module "ambassador" {
  depends_on     = [module.persistent_storage]
  source         = "./modules/ambassador"
  k8s_dns_prefix = local.k8s_dns_prefix
}
module "jaeger" {
  depends_on = [module.k8s]
  source     = "./modules/jaeger"
}
module "cert_manager" {
  depends_on = [module.ambassador, module.hono]
  source     = "./modules/cert_manager"
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
  depends_on = [module.hono, module.ambassador, module.cert_manager]
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
  depends_on = [module.hono, module.ambassador, module.cert_manager]
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
      version = "~> 2.94.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.7.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.4.1"
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
  scope                            = data.terraform_remote_state.storagestate.outputs.rg_id
  role_definition_name             = "Owner" # This needs to be changed to a more restrictive role
  principal_id                     = module.k8s.mi_principal_id
  skip_service_principal_aad_check = true
}
 