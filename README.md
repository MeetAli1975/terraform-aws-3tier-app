# Terraform AWS 3-Tier Infrastructure

Production-grade Terraform configuration for deploying a complete 3-tier web application infrastructure on AWS with multi-environment support (Development, Staging, Production).

## Architecture

This Terraform configuration deploys:

- **Web Tier:** Application Load Balancer (ALB) distributing traffic across EC2 instances
- **Application Tier:** Auto-scaling EC2 instances running Apache/PHP
- **Database Tier:** RDS MySQL database in private subnets with automated backups
- **Networking:** VPC with public/private subnets, NAT Gateway, Security Groups, and proper routing

## Features

- Multi-environment support (dev, staging, prod)
- Separate state files per environment
- Security groups with least-privilege access
- High availability (multi-AZ RDS for production)
- Health checks on ALB target group
- Encrypted database passwords (marked as sensitive)
- IAM roles for EC2 instances
- Automated backups and snapshots
- Environment-specific sizing and resource allocation

## Directory Structure

```
terraform-aws-3tier-app/
├── main.tf                 # Infrastructure resources (VPC, EC2, RDS, ALB)
├── variables.tf            # Input variables with validation
├── outputs.tf              # Output values for cross-stack reference
├── terraform.tfvars        # Default variable values
├── dev.tfvars              # Development environment overrides
├── staging.tfvars          # Staging environment overrides
├── prod.tfvars             # Production environment overrides
├── user_data.sh            # EC2 initialization script
└── .gitignore              # Git ignore patterns
```

## Prerequisites

- Terraform >= 1.0
- AWS Account with appropriate credentials
- AWS CLI configured with valid credentials
- `aws_region` set to a valid AWS region

## Deployment

### Initialize Terraform

```bash
terraform init
```

### Plan Deployment (Development)

```bash
terraform plan -var-file="dev.tfvars"
```

### Apply Configuration (Development)

```bash
terraform apply -var-file="dev.tfvars"
```

### Plan Deployment (Staging)

```bash
terraform plan -var-file="staging.tfvars"
```

### Apply Configuration (Staging)

```bash
terraform apply -var-file="staging.tfvars"
```

### Plan Deployment (Production)

```bash
terraform plan -var-file="prod.tfvars"
```

### Apply Configuration (Production)

```bash
terraform apply -var-file="prod.tfvars"
```

## Environment-Specific Configuration

### Development (`dev.tfvars`)
- Region: us-east-1
- Instance Type: t3.micro (1 instance)
- RDS: db.t3.micro, 20GB storage
- Multi-AZ: Disabled
- Backups: 7 days retention

### Staging (`staging.tfvars`)
- Region: us-east-1
- Instance Type: t3.small (2 instances)
- RDS: db.t3.small, 50GB storage
- Multi-AZ: Disabled
- Backups: 7 days retention

### Production (`prod.tfvars`)
- Region: us-east-1
- Instance Type: t3.medium (2 instances)
- RDS: db.t3.medium, 100GB storage
- Multi-AZ: Enabled (high availability)
- Backups: 30 days retention

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `aws_region` | AWS region | us-east-1 |
| `environment` | Environment name | dev, staging, prod |
| `vpc_cidr` | VPC CIDR block | 10.0.0.0/16 |
| `public_subnet_cidrs` | Public subnet CIDR blocks | ["10.0.1.0/24", "10.0.2.0/24"] |
| `private_subnet_cidrs` | Private subnet CIDR blocks | ["10.0.10.0/24", "10.0.11.0/24"] |
| `instance_type` | EC2 instance type | t3.micro, t3.small, t3.medium |
| `instance_count` | Number of EC2 instances | 1, 2 |
| `db_instance_class` | RDS instance class | db.t3.micro, db.t3.small |
| `db_allocated_storage` | RDS storage in GB | 20, 50, 100 |
| `db_name` | Database name | queensappdb |
| `db_username` | Database admin username | admin |
| `db_password` | Database admin password | (sensitive) |

## Outputs

After deployment, Terraform outputs:

- `application_url` - URL to access your application
- `alb_dns_name` - Load balancer DNS name
- `rds_address` - Database endpoint
- `ec2_instance_ids` - IDs of deployed instances
- `security_group_ids` - Security groups for reference

## Security Groups

- **ALB SG:** Allows inbound HTTP (80) and HTTPS (443) from anywhere
- **EC2 SG:** Allows inbound traffic from ALB on ports 80 and 8080
- **RDS SG:** Allows inbound MySQL (3306) traffic only from EC2 SG

## Best Practices Implemented

- **Least Privilege:** Security groups restrict traffic to minimum necessary
- **Separation of Concerns:** Public/private subnets separate web tier from database
- **High Availability:** Multi-AZ setup for production RDS
- **Sensitive Data:** Passwords marked as sensitive in outputs
- **State Management:** Environment-specific tfvars files
- **Tags:** Resources tagged with environment and project name
- **Validation:** Variables include validation rules

## Destroying Infrastructure

To tear down a specific environment:

```bash
terraform destroy -var-file="dev.tfvars"
```

**WARNING:** This will delete all resources including the RDS database. Ensure you have backups if needed.

## Cost Estimation

Use `terraform plan` output to estimate costs, or:

```bash
terraform plan -var-file="dev.tfvars" | grep "Plan:"
```

## Troubleshooting

### Instance cannot connect to database
- Check RDS security group allows traffic from EC2 SG on port 3306
- Verify RDS is in private subnets with NAT Gateway configured
- Check database endpoint in user_data matches RDS address output

### ALB returns 502 Bad Gateway
- Verify EC2 instances passed health checks (ALB target group)
- Check EC2 security group allows inbound traffic on port 8080 from ALB
- SSH into instance and verify Apache/PHP service is running

### State file conflicts
- Use separate tfvars files and state files for each environment
- Never commit sensitive tfvars files to version control
- Use `-lock-timeout=10m` if experiencing lock contention

## Contributing

When modifying this configuration:
1. Always test in `dev` environment first
2. Use `terraform plan` to review changes
3. Tag resources appropriately
4. Update this README with new variables or features
5. Never commit `.tfstate` or `.tfvars` files

## License

This Terraform configuration is part of the Queens Infrastructure Automation project.
