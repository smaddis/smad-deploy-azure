# Smad-deploy-azure architecture description
 
This is a architectural description of the smad-deploy-azure
 
|Folder|Description|Depends on|
|------|----------|-------|
|[./](#Root-module)|Root module||
|./modules|Modules used by the script. |
|[../k8s](#Kubernetes-deployment-module)|Module for  creating kubernetes cluster to Azure (AKS)
|[../container_deployment](#Container-deployment-module)|Handles deployment of the stack via Helm to k8s cluster. Holds all the information regarding setting up the cloud environment| k8s
|[../container_registry](#Contrainer-registry-module)| Creates ACR for k8s cluster. **Currently not used**| k8s
|[../datam](#Datamanager-module)|Gets value from remote state file located in Azure subscription.
|[../tfstate_storage_azure](#Terraform-state-module)|Creates resource group for terraform state file|
|[../storage_rg](#Storage-resource-group)|Creates separate resource group for persistent data needs|




Every module follows the conventional Terraform naming scheme, and therefore has `main.tf`, `variables.tf` and `outputs.tf` files.

## Description
![TF script diagram view](./tfscript_diagram.png "Diagram")

## Root module


### `main.tf`

Used for deploying modules and setting up proper environment for kubernetes and helm providers, and azurerm backend.

Project name is prefixed with Terraform Workspace name.

#### `module "k8s_cluster_azure"`
 
Uses module specified in `./modules/k8s/`  folder for deploying Kubernetes cluster under `k8test-rg resource group`. Node count of cluster is controlled  by `k8s_agent_count` variable, where node count for default terraform workspace is 3, and non-default workspace is 2. `use_separate_storage_rg` variable controls whether separate resource group for storage purposes is created

##### `resource "azurerm_role_assignment" "k8s-storage-role-ass"`

Role assingment for separate resource group. Gets scope value from datamodule. Created only when `use_separate_storage_rg` is true.

#### `module "container_deployment"`

Uses module specified in `./modules/container_deployment/`  folder for deploying services on previously created Kubernetes cluster. Custom MongoDB username and password could be supplied to services, otherwise default is used.

Kubernetes and Helm providers are configured with outputs acquired from created k8s cluster module.

### `variables.tf`

#### ``variable "project_name"``

Used to specify project name. No need to change because Terraform Workspace prefix can create unique project names.

#### ``variable "k8s_agent_count"``

Node count for clusters using "default" Terraform Workspace

#### ``variable "testing_k8s_agent_count"``

Node count for clusters using non-default Terraform Workspace. Used for test deployments.


#### ``variable "mongodb_username"``

MongoDB username for deployed MongoDB instance. Can be specified with .tfvars

#### ``variable "mongodb_password"``

MongoDB password for deployed MongoDB instance. Can be specified with .tfvars

### `outputs.tf`

Outputs for kube config files and path's for it

#### `example.tfvars`

Example .tfvars for supplying custom variables.

## Kubernetes deployment module

This module can be deploy independetly because of provider specifications in module.

### `main.tf`


Creates resource group for Kubernetes cluster with project name and resource_group_name suffix specified in variables.

Log analytics workspace is also created with ContainerInsights name.

Kubernetes cluster is created with `resource "azurerm_kubernetes_cluster" "k8s_cluster"` under previously created resource group.

#### `resource "kubernetes_storage_class" "azure-disk-retain"`

Creates storage class with reclaim policy of retain. Resource group is defined with the `separate_storage_rg` variable, and if it is false then `null` value is used. This means that when resource group is `null` then resource group is created under the same resource group where k8s_cluster is.

#### ``resource "kubernetes_persistent_volume_claim" "example"``

Creates persistent volume claim for MongoDB.

### `variables.tf` 

Contains variables for naming all the resources and specifying node count. Project name, k8s_agent_count and resource_group_name_suffix variables can be set from root main.tf

### `outputs.tf` 

Output values acquired from k8s_clusters kube config. 
THese include client keys, cerficates, usernames, passwords and hosts for k8s cluster.


## Container deployment module

**Depends on `k8s module`**

This module handles all the aspects of deploying smad service stack. Which consists of Hono, MongoDB, Prometheus, Jaeger and Grafana. Uses Helm for deployment.

### `main.tf`

#### `resource "helm_release" "mongodb"`

Values used by service are supplied by `mongo_values.yaml` -file. Sensitive values such as usernames and passwords acquired from variables.tf

#### `resource "helm_release" "hono"`

Deploys Hono from Helm Chart. Uses `hono_values.yaml` for configuration and sensitive values from MongoDB are acquired from variables.tf. Deploys only after kube-prometheus-stack has succesfully deployed.

#### `resource "helm_release" "ingress-nginx"`

Used for creating ingress for Jaeger-query service

#### `resource "helm_release" "jaeger-operator"`

Deploys jaeger-operator, and is configured with values from `jaeger_values.yaml`

#### ``resource "kubernetes_config_map" "grafana_hono_dashboards"``

Creates kubernetes config map and supplies preconfigured Grafana dashboards via .json

#### `resource "helm_release" "kube-prometheus-stack"`

Deploys kube-prometheus-stack which consists of Prometheus, kube metrics and grafana. 
### `variables.tf`

Holds information related to mondogb username and passwords. Can be configured independetly otherwise defaults used.

### `hono_values.yaml`

Configures Hono helm chart to use separately deployed jaeger-operator.
Also configures to use separately deployed MongoDB for Hono device registry.
Other services provided by Hono Helm chart are disabled. Smad-deploy-azure uses separately deployed and configured services.

### `jaeger_values.yaml`

TBC

### `prom_values.yaml`

Configures grafana, prometheus as LoadBalancers, and configures scrape configs for Hono.

### `mongodb_values.yaml`

Configures persistence volumeclaim for MongoDB, and enables materis and statefuls set.

## Contrainer registry module

**NOT USED**

**Depends on k8s module**

### `main.tf`

Creates Azure Container registry in the same resource group as k8s modules.

Assigns acrpull role for k8s cluster
### `variables.tf`

Variables for naming resources.

### `outputs.tf`

Output values for ACR. Containing id, login url, username and password.

## Datamanager module

This module used for getting data from remote Terraform state for creating role assingment in root folders `main.tf`

### `main.tf`

Data resource which uses previously created tfstate naming for getting informatio of created tfstate in Azure subscription

### `variables.tf`

### `outputs.tf`

Outputs remote state's id.

## Terraform state module

### `main.tf`
This module is to be ran separately, because it creates needed Terraform State files and storage account and container to Azure

### `variables.tf`

Hold variables for naming resources created by this module.

### `outputs.tf`

Output values four resource group, storage account and storate container.


## Storage resource group

This modules creates separate resource group for persistent volume claim.

### `main.tf`

Establish azurerm backend with previously set naming for tfstate files, and create resource group named `storage-resource-group"`

### `variables.tf`


### `outputs.tf`

Output value of created resource group's id.
