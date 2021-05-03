# Setup and configuration
## Project description
Project description comes here
SMAD specific Kuksa yms.

## Setup

### Prerequisities

- [Azure subscription](https://azure.microsoft.com/en-us/free/)

### Tools needed 

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (local environment) or [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)
- [Terraform](https://www.terraform.io/downloads.html) (version >= 0.14)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)

### Other helpful tools (not needed for setup)

- [Kubectx](https://github.com/ahmetb/kubectx)
- [Helm](https://helm.sh/docs/intro/install/)

### Infrastucture preparation for Kuksa Cloud

In order to deploy SMAD specific Kuksa Cloud, Terraform is first used create necessary infrastucture resources into Microsoft Azure.

#### Authenticate to Azure

Be sure to authenticate to Azure using Azure CLI before running these Terraform scripts.

If you are running these scripts in Azure Cloud Shell you are already authenticated.

Otherwise, you can login using, for example, Azure CLI interactively:
`$ az login`

For other login options see Azure documentation provided by Microsoft:
https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli


#### Select a subscription

After you authenticate with Azure CLI, check that the selected 
subscription is the one you want to use:
`$ az account show --output table`

You can list all subscriptions you can use:
`$ az account list --output table`

To change your selected subscription
`$ az account set -s <$SUBSCRIPTION_ID_OR_NAME>`

#### Terraform Workspaces

It is recommended that you familiarize yourself with [Terraform Workspaces](https://www.terraform.io/docs/language/state/workspaces.html) concept and utilize them when using these scripts.

Create a new workspace named e.g. 'development' with `terraform workspace new development` before creating any resources other than shared state you
- Enable creation of multiple AKS clusters within the same state file
- Prevent accidental deletion of other clusters within the same state file

#### Setting variables before deploying resources

TODO: real world example!!!

##### via a tfvars file
Run `$ terraform apply -var-file=./example.tfvars` to set variables from 'example.tfvars' -file.
##### via command line arguments
Run `$ terraform apply -var='foo=bar'` to set a variable named 'foo' to have value 'bar' via command line.

#### Terraform plan

Run `$ terraform plan` to see the resources that will be deployed.

#### 0. Create a storage account to store shared state for Terraform
[Shared state](https://www.terraform.io/docs/language/state/remote.html) should always be preferred when working with Terraform.

In order to create one you run `$ terraform apply './modules/tfstate_storage_azure/'` module.

This creates:
- Azure Resource Group (default name 'kuksatrng-tfstate-rg')
- Azure Storage Account (default name 'kuksatrngtfstatesa')
- Azure Storage Container (default name 'tfstate')

You can customize naming in './modules/tfstate_storage_azure/variables.tf'.
Check file content for naming restrictions and details.

#### 1. Deploy the SMAD stack

In order to deploy a K8S cluster and the resources within it with default parameters (see variables.tf) run `$ terraform apply` in the root folder.

##### Workspace-specific configurations

TODO:  real world example!!!

###### Default workspace:
Resources are not prefixed, so only one instance of the deployment can be set up at a time. The cluster is assigned 3 nodes in the default workspace configuration.
###### Non-default workspace:
Resources are prefixed, so multiple instances of the deployment can be set up at a time. The cluster is assigned 2 nodes in the non-default workspace configuration.


## Configuration

### Modifying resources created by Terraform

Resources created by Terraform should be modified via Terraform. If you modify resources created by Terraform using e.g. Kubectl, you may end up in a situation where terraform state is out of sync. 

If you change the configuration by e.g. changing the code and run `terraform apply`, Terraform will try to modify the resources in place whenever possible. If in-place modification is not possible, Terraform will first  destroy and then apply the modified resources. Run `terraform plan` to see the changes.

#### Using the target flag 

The `-target` flag can be used to apply and destroy only specific resources: 
`terraform apply -target=module.container_deployment.helm_release.mongodb`

Note that resources that depend on the targeted resource will also be destroyed if you run `terraform destroy -target`. 

Similarly, when running `terraform apply -target`, if resources that are needed by the targeted resource do not exist, Terraform cannot apply the targeted resources.

## Testing that Hono works

`tests/honoscript` folder has a shell script that can be used to quickly verify that Hono is running properly. Refer to `tests/honoscript/README.md` for more details.
