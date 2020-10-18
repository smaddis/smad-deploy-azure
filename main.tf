locals {
  project_name    = terraform.workspace == "default" ? var.project_name : "${terraform.workspace}${var.project_name}"
  k8s_agent_count = terraform.workspace == "default" ? var.k8s_agent_count : var.testing_k8s_agent_count
  k8s_dns_prefix  = terraform.workspace == "default" ? var.k8s_dns_prefix : "${terraform.workspace}-${var.k8s_dns_prefix}"
  domain_name     = format("%s.westeurope.cloudapp.azure.com", local.k8s_dns_prefix)
  email           = "email@example.com"
}

# module "tfstate_storage_azure" {
#     source  = "./modules/tfstate_storage_azure"
#
#     location = "West Europe"
#     project_name = "kuksatrng"
#     environment = "development"
#     tfstate_storage_account_name_suffix = "tfstatesa"
# }

module "k8s_cluster_azure" {
<<<<<<< HEAD
  source                         = "./modules/k8s"
  k8s_agent_count                = local.k8s_agent_count
  k8s_resource_group_name_suffix = var.k8s_resource_group_name_suffix
  project_name                   = local.project_name
  k8s_dns_prefix                 = local.k8s_dns_prefix
  use_separate_storage_rg        = var.use_separate_storage_rg
}

#module "container_registry_for_k8s" {
#  source                                   = "./modules/container_registry"
#  container_registry_resource_group_suffix = var.container_registry_resource_group_suffix
#  project_name                             = local.project_name
#  k8s_cluster_node_resource_group          = module.k8s_cluster_azure.k8s_cluster_node_resource_group
#  k8s_cluster_kubelet_managed_identity_id  = module.k8s_cluster_azure.kubelet_object_id
#}

module "container_deployment" {
  depends_on       = [module.k8s_cluster_azure]
  source           = "./modules/container_deployment"
  mongodb_username = var.mongodb_username
  mongodb_password = var.mongodb_password
  k8s_dns_prefix   = local.k8s_dns_prefix
  domain_name      = local.domain_name
  #depends_on here or no need? 
  cluster_name = tostring(module.k8s_cluster_azure.k8s_cluster_name)

}

module "datamodule" {
  source = "./modules/datam"
}

module "influxdb" {
  depends_on = [module.k8s_cluster_azure]
  source     = "./modules/influxdb"
  #  count      = var.enable_influxdb_module ? 1 : 0
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
  depends_on = [module.container_deployment]
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
  depends_on = [module.container_deployment]
  wait       = true
  count      = length(data.kubectl_path_documents.tls_mappings.documents)
  yaml_body  = element(data.kubectl_path_documents.tls_mappings.documents, count.index)
=======
    source = "./modules/k8s"

    k8s_agent_count = var.k8s_agent_count
}

module "container_registry_for_k8s" {
    source = "./modules/container_registry"

    k8s_cluster_node_resource_group = module.k8s_cluster_azure.k8s_cluster_node_resource_group
    k8s_cluster_kubelet_managed_identity_id = module.k8s_cluster_azure.kubelet_object_id
>>>>>>> fe425d1 (WIP Add Azure Key Vault creation and K8S CSI provider)
}
#########################
#########################
#########################
#########################

module "keyvault_for_secrets" {
    source = "./modules/keyvault"

    policies = {
        # full_permission = {
        #   tenant_id               = var.azure-tenant-id
        #   object_id               = var.kv-full-object-id
        #   key_permissions         = var.kv-key-permissions-full
        #   secret_permissions      = var.kv-secret-permissions-full
        #   certificate_permissions = var.kv-certificate-permissions-full
        #   storage_permissions     = var.kv-storage-permissions-full
        # }
        read_policy_for_k8s_kubelet = {
        tenant_id               = module.k8s_cluster_azure.mi_tenant_id
        object_id               = module.k8s_cluster_azure.kubelet_object_id
        key_permissions         = var.kv-key-permissions-read
        secret_permissions      = var.kv-secret-permissions-read
        certificate_permissions = var.kv-certificate-permissions-read
        storage_permissions     = var.kv-storage-permissions-read
        }
    }

}

module "k8s_csi_driver_azure"{
    source = "./modules/k8s_csi_driver_azure"

    k8s_host = module.k8s_cluster_azure.host
    k8s_username = module.k8s_cluster_azure.cluster_username
    k8s_password = module.k8s_cluster_azure.cluster_password
    k8s_client_cert = module.k8s_cluster_azure.client_certificate
    k8s_client_key = module.k8s_cluster_azure.client_key
    k8s_cluster_ca_cert = module.k8s_cluster_azure.cluster_ca_certificate

}

terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.45.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.1.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.2"
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
    resource_group_name = "kuksatrng-tfstate-rg"
    # Set to "${lower(var.project_name)}${var.tfstate_storage_account_name_suffix}"
    storage_account_name = "kuksatrngtfstatesa"
    # Set to var.tfstate_container_name
    container_name = "tfstate"
    # Set up "${lower(var.project_name)}.tfstate"
    key = "kuksatrng.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.k8s_cluster_azure.host
  client_key             = base64decode(module.k8s_cluster_azure.client_key)
  client_certificate     = base64decode(module.k8s_cluster_azure.client_certificate)
  cluster_ca_certificate = base64decode(module.k8s_cluster_azure.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.k8s_cluster_azure.host
    client_key             = base64decode(module.k8s_cluster_azure.client_key)
    client_certificate     = base64decode(module.k8s_cluster_azure.client_certificate)
    cluster_ca_certificate = base64decode(module.k8s_cluster_azure.cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = module.k8s_cluster_azure.host
  client_key             = base64decode(module.k8s_cluster_azure.client_key)
  client_certificate     = base64decode(module.k8s_cluster_azure.client_certificate)
  cluster_ca_certificate = base64decode(module.k8s_cluster_azure.cluster_ca_certificate)
  load_config_file       = false
  apply_retry_count      = 15
}

resource "azurerm_role_assignment" "k8s-storage-role-ass" {
  count                            = var.use_separate_storage_rg ? 1 : 0
  scope                            = module.datamodule.storagestate_rg_id
  role_definition_name             = "Owner" # This needs to be changed to a more restrictive role
  principal_id                     = module.k8s_cluster_azure.mi_principal_id
  skip_service_principal_aad_check = true
}
