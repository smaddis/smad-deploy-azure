# Setup

## Prerequisities

- [Azure subscription](https://azure.microsoft.com/en-us/free/)

## Tools needed 

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (local environment) or [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)
- [Terraform](https://www.terraform.io/downloads.html) (version >= 0.14)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)

## Other helpful tools (not needed for setup)

- [Kubectx](https://github.com/ahmetb/kubectx)
- [Helm](https://helm.sh/docs/intro/install/)

## Infrastucture preparation for Kuksa Cloud

In order to deploy SMAD specific Kuksa Cloud, Terraform is first used create necessary infrastucture resources into Microsoft Azure.

### Authenticate to Azure

Be sure to authenticate to Azure using Azure CLI before running these Terraform scripts.

If you are running these scripts in Azure Cloud Shell you are already authenticated.

Otherwise, you can login using, for example, Azure CLI interactively:
```
$ az login
```

For other login options see Azure documentation provided by Microsoft:
https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli


### Select a subscription

After you authenticate with Azure CLI, check that the selected 
subscription is the one you want to use:
```
$ az account show --output table
```

You can list all subscriptions you can use:
```
$ az account list --output table
```

To change your selected subscription
```
$ az account set -s <$SUBSCRIPTION_ID_OR_NAME>
```

### Setting variables before deploying resources

#### via a tfvars file
Run 
```
$ terraform apply -var-file=./example.tfvars
``` 
to set variables from 'example.tfvars' -file.
#### via command line arguments
Run 
```
$ terraform apply -var=use_separate_storage_rg=true
``` 
to set a variable named 'use_separate_storage_rg' to have value 'true' via command line. With this variable set as 'true', you effectively switch the K8S cluster to use a separate resource group for storage.

### Terraform plan

Run `$ terraform plan` to see an overview of the resources that will be deployed.

### Create a storage account to store shared state for Terraform
[Shared state](https://www.terraform.io/docs/language/state/remote.html) should always be preferred when working with Terraform.

In order to create one run 
```
$ terraform apply './modules/tfstate_storage_azure/'
```

This creates:
- Azure Resource Group (default name 'kuksatrng-tfstate-rg')
- Azure Storage Account (default name 'kuksatrngtfstatesa')
- Azure Storage Container (default name 'tfstate')

You can customize naming in './modules/tfstate_storage_azure/variables.tf'.
Check file content for naming restrictions and details.

# Terraform Workspaces

It is recommended that you familiarize yourself with [Terraform Workspaces](https://www.terraform.io/docs/language/state/workspaces.html) concept and utilize them when using these scripts.

By using a non-default workspace you
- Enable creation of multiple AKS clusters with the same configuration
- Prevent accidental deletion of other clusters within the same subscription

Workspaces can be created by running 
```
$ terraform workspace new <workspace_name>
``` 
and selected by running 
```
$ terraform workspace select <workspace_name>
```

## Workspace-specific configurations

### Default workspace:
Resources are not prefixed, so only one instance of the deployment can be set up at a time. The cluster is assigned 3 nodes in the default workspace configuration.

### Non-default workspace:
Resources are prefixed, so multiple instances of the deployment can be set up at a time. The cluster is assigned 2 nodes in the non-default workspace configuration.

# Deploy the SMAD stack

## Deploy the main service stack with default parameters (see variables.tf)
If you want to use a separate resource group for storage, skip this step.

```bash
$ terraform apply ./
```

## OPTIONAL: Separate resource group

1. Create separate resource group for databases
```
$ terraform apply ./modules/storage_rg
```

2. Deploy the main service stack with `use_separate_storage_rg=true`
```
$ terraform apply -var=use_separate_storage_rg=true ./
```
# Configuration

## Modifying resources created by Terraform

Resources created by Terraform should be modified via Terraform. If you modify resources created by Terraform using e.g. Kubectl, you may end up in a situation where terraform state is out of sync. 

Modifying the resources is simply accomplished by editing the script and then running `terraform apply`.

If you change the configuration by e.g. changing the code and run `terraform apply`, Terraform will try to modify the resources in-place whenever possible. If in-place modification is not possible, Terraform will first  destroy and then apply the modified resources. Run `terraform plan` to see the changes.

### Using the -target flag 

The `-target` flag can be used to apply or destroy only specific resources: 
```
terraform apply -target=module.container_deployment.helm_release.mongodb
```

Note that resources that depend on the targeted resource will also be destroyed if you run `terraform destroy -target`. 

Similarly, when running `terraform apply -target`, if resources that are needed by the targeted resource do not exist, Terraform cannot apply the targeted resources.

# Testing that Hono works

`tests/honoscript` folder has a shell script that can be used to quickly verify that Hono is running properly. Refer to `tests/honoscript/README.md` for more detailed instructions.

# Known issues

## Delays with Hono resource deletion

If Hono is destroyed with `terraform destroy` without destroying the underlying K8S cluster, all of Hono's resources are not destroyed immediately even though Terraform (Helm) tells so. If you attempt to deploy Hono again immediately, Terraform (Helm) may show that Hono is deployed successfully, but in reality, most of the resources will be missing. 

Workarounds: 
- Wait around 30-60 minutes before deploying Hono again.
- Destroy the whole cluster (effectively the whole stack) and deploy it again (may be faster than the first option but you may lose some persistent data if not using the separate storage resource group).

## Storage persistence

If the whole service stack is destroyed and variable `use_separate_storage_rg` is `false` all peristent volumes will also be destroyed. This can be prevented by setting `use_separate_storage_rg` to `true`: when the service stack is destroyed, the persistent volumes will remain in the separate resource group. Currently this has some drawbacks: when the service stack is deployed again, the script will create a new persistent volume and data from the old persistent volume must be restored manually.

Workarounds:
- No workarounds currently.

## Separate storage resource group access delay

If the separate resource group for storage is used, a role will be created that grants the K8S cluster rights to access the separate resource group. It may take [up to 30 minutes](https://docs.microsoft.com/en-us/azure/role-based-access-control/troubleshooting#role-assignment-changes-are-not-being-detected) for Azure to propagate the permissions throughout the Azure subscription. Consequently, the K8S cluster may not be able to create the Persistent Volume Claim it needs for persistent data (e.g. for Hono device registry).

Workarounds:
- Run `$ terraform apply` again until the deployment succeeds.

