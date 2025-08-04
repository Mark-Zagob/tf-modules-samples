## My Terraform Modules AWS samples

These are some modules for aws 

## Features
- VPC with DNS support
- Management subnet fixed
- Public subnet for each AZ
- Private Subnets for Services
- Intra Subnets for internal services eg(database, lambda internal.....)

## Usage

### Basic Usage
```hcl
module "vpc" {
  source          = "git::https://github.com/Mark-Zagob/tf-modules-samples.git//modules/network"
  vpc_cidr        = "10.0.0.0/16"
  env_deploy      = "production"
  avai_zones      = data.aws_availability_zones.available.names
  services_subnets = ["web", "app", "cache"]
  intra_subnets   = ["db", "backup"]
  enable_natgw    = true
  
  tags = {
    Project     = "Ecommerce"
    ManagedBy   = "Terraform"
  }
}
```

### Outputs Reference
```hcl
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "management_subnet_id" {
  value = module.vpc.management_subnet_id
}
```

## Inputs

| Name             | Description                  | Type           | Default | Required |
|------------------|------------------------------|----------------|---------|----------|
| vpc_cidr         | CIDR block for VPC           | `string`       | n/a     | yes |
| env_deploy       | environment for deployment   | `string`       | n/a     | yes |
| avai_zones       | Availability Zones           | `list(string)` | n/a     | yes |
| services_subnets | private subnets with internet| `list(string)` | `[]`    | no |
| intra_subnets    | private subnets for internal | `list(string)` | `[]`    | no |
| tags             | Tags for all                 | `map(string)`  | `{}`    | no |
| enable_natgw     | natgw for services subnets   | `bool       `  | `true`  | no |
| natgw_per_az     | HA natgw in each az          | `bool`         | `false` | no |


## Outputs


## Network Architecture
```
VPC: ${var.vpc_cidr}
├── Management Subnet: 172.16.255.0/28 (fixed)
├── Public Subnets:
│   ├── ${az[0]}: cidrsubnet(vpc_cidr, 6, 0)
│   └── ${az[1]}: cidrsubnet(vpc_cidr, 6, 1)
├── Services Subnets:
│   ├── web-${az_short[0]}: cidrsubnet(vpc_cidr, 8, index+14)
│   ├── web-${az_short[1]}: ...
│   ├── app-${az_short[0]}: ...
│   └── ...
└── Intra Subnets:
    ├── db-${az_short[0]}: cidrsubnet(vpc_cidr, 10, index+1000)
    └── ...
```