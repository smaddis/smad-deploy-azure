Just practice based on https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks

- TODO: create AD group via this Terraform script.
- TODO: assign user as cluster admin via this Terraform script.
- TODO: improve README

### Infrastucture preparation for Kuksa Cloud

In order to deploy Kuksa Cloud, Terraform -tool is first used create 
necessary infrastucture resources into Microsoft Azure.

#### Prerequisities


##### Authenticate

Be sure to authenticate to Azure using Azure CLI 
before runningthese Terraform scripts.

If you are running these scripts in Azure Cloud Shell
you are already authenticated.

Otherwise, you can login using, for example, Azure CLI interactively:
`$ az login`

For other login options see Azure documentation provided by Microsoft:
https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli


##### Select a subscription

After you authenticate with Azure CLI, check that the selected 
subscription is the one you want to use:
`$ az account show --output table`

You can list all subscriptions you can use:
`$ az account list --output table`

To change your selected subscription
`$ az account set -s <$SUBSCRIPTION_ID_OR_NAME>`


#### 0.Create a storage account to store shared state for Terraform
Shared state should always be preferred when working with Terraform.

In order to create one you run `$ terraform apply './modules/tfstate_storage_azure/'` module.

This creates:
- Azure Resource Group (default name 'kuksatrng-tfstate-rg')
- Azure Storage Account (default name 'kuksatrngtfstatesa')
- Azure Storage Container (default name 'tfstate')

You can customize naming in './modules/tfstate_storage_azure/variables.tf'.
Check file content for naming restrictions and details.


#### Working with Terraform Workspaces

It is recommended that you familiarize yourself with Terraform Workspaces 
concept and utilize them when using these scripts.
(https://www.terraform.io/docs/language/state/workspaces.html)

Creating e.g. new workspace named 'development' with `terraform workspace new development` 
before creating any resources other than shared state you e.g.
- Enable creation of multiple AKS clusters within the same state file
- Prevent accidental deletion of other clusters within the same state file

Other option is to customize state storage parameters e.g. state file name and create 
a new AKS cluster there.

With these scripts use of workspaces is encouraged.


#### 1. Create a Kubernetes cluster in Azure Managed Kubernetes Service (AKS)
 
In order to create one with default parameters (see variables.tf) you run  `$ terraform apply './'`.
You can also run `$ terraform apply './' -var-file='./example.tfvars'` to get variables from 'example.tfvars' -file.
You can use example.tfvars to e.g. customize naming of various objects.


#### 2. Continue Kuksa Cloud deployment with kubectl, docker and Azure CLI

 


#### 5. Role-based access control (RBAC), Azure Active Directory (AAD) and namespaces

To enable RBAC through AAD via this Terraform plan the following steps were done:

1. Added a role_based_access_control-block to resource "azurerm_kubernetes_cluster" found in modules/k8s/main.tf.
- that block contains an array named admin_group_object_ids, which contains the id of an AD group. That AD group contains admins of the cluster. Currently, creating the group and adding admins is a manual process. The group id can be queried via Azure CLI or Azure Portal.
2. After enabling AAD/RBAC, K8S csi driver installation needs sufficient K8S cluster credentials. One easy way of providing them is to use kubeconfig with --admin flag:
- `az aks get-credentials -g <RESOURCE_GROUP_NAME> -n <CLUSTER_NAME> --admin`. This creates an entry in the kubeconfig (default path is ~/.kube/config).
3. Added following lines to provider "helm" in modules/k8s_csi_driver_azure/main.tf: 
- `config_path = "~/.kube/config"`
- `config_context = "<ADMIN_CONTEXT_NAME_HERE>"`
- Note: do not specify username and password if using kubeconfig to authenticate.
4. Then, this guide was followed: https://docs.microsoft.com/en-us/azure/aks/azure-ad-rbac with following exceptions: 
- In step `Create demo users in Azure AD`, new users weren't created. Instead, 
$AKSDEV_ID and $AKSSRE_ID were replaced by existing users' ids.
- Note: if you are in the cluster admin AD group, you will see all cluster resources regardless of whether you use cluster admin or cluster user context (acquired via the az aks get-credentials command).
- Note: if you destroy the resources and then apply them again, you may need to acquire new credentials to kubeconfig to be able to install the K8S CSI driver.

After doing those steps, with your cluster user credentials, you should only be able to see and modify resources in specific namespaces.


#### Misc. links regarding roles and namespaces:
https://docs.microsoft.com/en-us/azure/aks/azure-ad-rbac

https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group

https://www.danielstechblog.io/azure-kubernetes-service-azure-rbac-for-kubernetes-authorization/

https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/aks/managed-aad.md

https://docs.microsoft.com/en-us/azure/aks/manage-azure-rbac

https://registry.terraform.io/

https://www.danielstechblog.io/terraform-deploy-an-aks-cluster-using-managed-identity-and-managed-azure-ad-integration/

https://docs.microsoft.com/en-us/azure/aks/managed-aad

https://www.chriswoolum.dev/aks-with-managed-identity-and-terraform

https://docs.microsoft.com/en-us/azure/aks/kubernetes-portal#troubleshooting <-- Azure Portal resource view

https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/role-based-access-control/built-in-roles.md#azure-kubernetes-service-cluster-user-role

https://kubernetes.io/docs/reference/access-authn-authz/rbac/

