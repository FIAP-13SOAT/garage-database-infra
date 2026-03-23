# garage-database-infra

Dedicated Terraform repository for the Garage project's RDS PostgreSQL database infrastructure. This repository manages the database instance, security groups, subnet groups, and SSM parameters independently from the main cloud infrastructure.

## Resources Managed

- **RDS PostgreSQL Instance** — `db.t3.micro` running PostgreSQL 16.11
- **DB Subnet Group** — Places the RDS instance in private subnets across two availability zones
- **RDS Security Group** — Controls ingress from EKS nodes and Lambda functions on port 5432
- **SSM Parameters** — Publishes `/garage/prod/db/endpoint` and `/garage/prod/db/secret_arn` for service discovery

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with valid credentials
- Access to the S3 state bucket: `garage-terraform-state-211125475874`
- The `garage-cloud-stack` must be applied first (provides VPC, subnets, and security group outputs)

## Deployment Order

This repository depends on outputs from `garage-cloud-stack`. Always follow this order:

1. **garage-cloud-stack** — Apply first to provision VPC, EKS, Lambda, and expose network outputs
2. **garage-database-infra** — Apply second to provision RDS and publish SSM parameters
3. **tech-challange** (K8s deploy) — Reads DB connection details from SSM parameters

## Usage

```bash
cd infra
terraform init
terraform plan
terraform apply
```

## Repository Structure

```
garage-database-infra/
├── .github/
│   └── workflows/
│       └── pipeline.yml      # CI/CD pipeline (triggers on push to master)
├── infra/
│   ├── main.tf               # Provider, backend, locals, remote state
│   ├── rds.tf                # RDS instance and DB subnet group
│   ├── security_groups.tf    # RDS security group and ingress rules
│   ├── ssm_parameter.tf      # SSM parameters for DB endpoint and secret ARN
│   ├── outputs.tf            # Terraform outputs
│   ├── variables.tf          # Input variables
│   └── terraform.tfvars      # Variable values
├── docs/
│   └── MIGRATION.md          # State migration procedure
└── README.md
```

## Migration

If migrating existing RDS resources from `garage-cloud-stack`, see [docs/MIGRATION.md](docs/MIGRATION.md) for the step-by-step state migration procedure.
