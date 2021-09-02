# Smad service stack deployment to Azure

[![Terraform Validate and plan](https://github.com/smaddis/smad-deploy-azure/actions/workflows/terraform-plan.yml/badge.svg)](https://github.com/smaddis/smad-deploy-azure/actions/workflows/terraform-plan.yml)

This repository consists of Terraform scripts and Bash tools for deploying service stack for the SMAD project to Azure. Main terraform script deploys
- Eclipse Hono
- Prometheus monitoring
- Jaeger tracing
- MongoDB for device registry
- Grafana and set of dashboards

Included testing tools allow setting up and testing deployed Hono instance.

## Documentation

More in-depth setup and configuration can be found at [SETUP.md](./docs/SETUP.md)

Architectural description of the codebase can be found at [ARCHITECTURE.md](./docs/ARCHITECTURE.md)

## Usage

1. Create Terraform State storage group and account to Azure
```bash
$ terraform apply ./modules/tf_state_storage_azure
```
### No separate storage resource group (default)

2. Remember to edit `main.tf` email variable to a real one for TLS certificate
2. Deploy main service stack

```bash
$ terraform apply ./
```

### OPTIONAL: Separate resource group

2. Create separate resource group for databases
```
$ terraform apply ./modules/storage_rg
```

3. Deploy with `use_separate_storage_rg=true`
```
$ terraform apply -var=use_separate_storage_rg=true ./
```

## After deployment

After deployment you can use following url for accessing services and adapters {terraform-workspace}.westeurope.cloudapp.azure.com

Hono registry: `{terraform-workspace}.westeurope.cloudapp.azure.com/registry`

Grafana: `{terraform-workspace}.westeurope.cloudapp.azure.com/grafana`

Jaeger: `{terraform-workspace}.westeurope.cloudapp.azure.com/jaeger`

## License
[MIT License](./LICENSE)

## Authors

This project was created by student group called  SMADYASP, from University Of Oulu, Finland