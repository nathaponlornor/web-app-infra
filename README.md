# Web App Infrastructure (Terragrunt + GitHub Actions CI/CD)

## Project Structure

```
modules/                    # Reusable Terraform modules
├── vpc/                    # VPC, subnets, NAT, routing
├── alb/                    # ALB, target group, listener
├── ecs/                    # ECS cluster, service, task, ASG
├── rds/                    # RDS PostgreSQL, security group
└── cdn/                    # S3 + CloudFront + WAF

live/                       # Terragrunt live config (per environment)
├── terragrunt.hcl          # Root config (provider, backend — DRY)
└── dev/
    ├── env.hcl             # Environment-specific variables
    ├── vpc/terragrunt.hcl
    ├── alb/terragrunt.hcl  # depends on: vpc
    ├── ecs/terragrunt.hcl  # depends on: vpc, alb
    ├── rds/terragrunt.hcl  # depends on: vpc, ecs
    └── cdn/terragrunt.hcl

.github/workflows/
├── terraform-plan.yml      # PR → plan all modules
└── terraform-apply.yml     # Merge → apply all modules
```

## Dependency Graph

```
vpc → alb → ecs → rds
vpc → cdn (independent)
```

## Deploy

```bash
# Deploy entire environment
cd live/dev
terragrunt run-all apply

# Deploy single module
cd live/dev/vpc
terragrunt apply

# Plan everything
cd live/dev
terragrunt run-all plan

# Destroy everything (reverse order)
cd live/dev
terragrunt run-all destroy
```

## Add a New Environment

```bash
cp -r live/dev live/prod
# Edit live/prod/env.hcl with prod values
```
