# Smad service stack deployment

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

1. `$ terraform apply ./modules/tf_state_storage_azure`
2. `$ terraform apply ./modules/storage_rg`
3. `$ terraform apply ./`

## License
[MIT License](./LICENSE)

## Authors

This project was created by student group called  SMADYASP, from University Of Oulu, Finland