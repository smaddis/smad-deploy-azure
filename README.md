Just practice based on https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks

### Infrastucture preparation for Kuksa Cloud

In order to deploy Kuksa Cloud, Terraform -tool is first used create necessary infrastucture resources into Microsoft Azure.

#### Prerequisities


##### Authenticate

Be sure to authenticate to Azure using Azure CLI before running these Terraform scripts.

If you are running these scripts in Azure Cloud Shell you are already authenticated.

Otherwise, you can login using, for example, Azure CLI interactively:
`$ az login`

For other login options see Azure documentation provided by Microsoft:
https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli


##### Select a subscription

After you authenticate with Azure CLI, check that the selected subscription is the one you want to use:
`$ az account show --output table`

You can list all subscriptions you can use:
`$ az account list --output table`

To change your selected subscription
`$ az account set -s <$SUBSCRIPTION_ID_OR_NAME>`


#### 0.Create a storage account to store shared state for Terraform
Shared state should always be preferred when working with Terraform.

In order to create one you run `$ terraform apply './modules/tfstate_storage_azure/main.tf'` module.

This creates:
- Azure Resource Group (default name 'kuksatrng-tfstate-rg')
- Azure Storage Account (default name 'kuksatrngtfstatesa')
- Azure Storage Container (default name 'tfstate')

You can customize naming in variables.tf. Check file content for naming restrictions and details.


#### 1. Create a Kubernetes cluster in Azure Managed Kubernetes Service (AKS)
 
In order to create one you run `$ terraform apply 'main.tf' -var-file='./example.tfvars'`

You can also run `$ terraform apply 'main.tf'`
You can customize naming using .tfvars see example.tfvars.

#### 2. Continue Kuksa Cloud deployment with kubectl, docker and Azure CLI

 
