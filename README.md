Just practice based on https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks

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

 

