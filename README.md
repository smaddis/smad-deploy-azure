# Smad service stack deployment to Azure

[![Terraform Validate and plan](https://github.com/smaddis/smad-deploy-azure/actions/workflows/terraform-plan.yml/badge.svg)](https://github.com/smaddis/smad-deploy-azure/actions/workflows/terraform-plan.yml)

This repository consists of Terraform scripts and Bash tools for deploying service stack for the SMAD project to Azure. Main terraform script deploys
- Eclipse Hono
- Prometheus monitoring
- Jaeger tracing
- MongoDB for device registry
- InfluxDB for monitoring data
- Grafana and set of dashboards
- Ambassador

Included testing tools allow setting up and testing deployed Hono instance.

## Documentation

More in-depth setup and configuration can be found at [SETUP.md](./docs/SETUP.md)

Architectural description of the codebase can be found at [ARCHITECTURE.md](./docs/ARCHITECTURE.md)

## Usage

### 1. Create Terraform State storage group and account to Azure

```bash
$ terraform -chdir=00_tfstate_storage init 
$ terraform apply ./00_tfstate_storage
```

### 2. Create separate resource group for persistent data

```bash
$ cd 01_storage_rg
$ terraform init
```
2. Create a Terraform workspace

```bash
$ terraform workspace new [WORKSPACE NAME]
```

2. Deploy persistent data file shares

```bash
$ cd ../
$ terraform apply ./01_storage_rg
```

### 3. Deploy main service stack

Remember to edit `main.tf` email variable to a real one for TLS certificate

```bash
$ cd 02_deployHono
$ terraform init
```

Create a Terraform workspace. Important: Use same workspace name as before in 01_storage_rg!

```bash
$ terraform workspace new [WORKSPACE NAME]
$ terraform apply
```

## After deployment

After deployment you can use following url for accessing services and adapters {terraform-workspace}.westeurope.cloudapp.azure.com

Hono registry: `{terraform-workspace}.westeurope.cloudapp.azure.com/registry`

Grafana: `{terraform-workspace}.westeurope.cloudapp.azure.com/grafana`

Jaeger: `{terraform-workspace}.westeurope.cloudapp.azure.com/jaeger`

## License
[MIT License](./LICENSE)

## Authors

This project was created by student group called SMADYASP, from University Of Oulu, Finland. Further development was done by University of Oulu. 
