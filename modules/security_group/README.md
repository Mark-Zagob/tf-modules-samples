## Security group module

## Features
- Ingress rules for traffic to services in vpc
- Egress rules for traffic from services in vpc

## Usage

### Basic Usage
```hcl
module "security_group" {
  source          = "git::https://github.com/Mark-Zagob/tf-modules-samples.git//modules/security-group"
  name            = "sg001"
  vpc_id          = "vpc-0235521bfcebkoa36"
  env_deploy      = "production"
  description = var.sg_description
  ingress_rules = var.sg_ingress_rule
  egress_rules = var.sg_egress_rules
}
```

### Outputs Reference
```hcl
output "security_group_id" {
  value = module.security-group.security_group_id
}

output "security_group_arn" {
  value = module.security-group.security_group_arn
}
```

## Inputs

| Name             | Description                  | Type           | Default | Required |
|------------------|------------------------------|----------------|---------|----------|
| vpc_id           | ID of VPC                    | `string`       | n/a     | yes |
| env_deploy       | environment for deployment   | `string`       | n/a     | yes |
| name             | name of security group       | `string`       | n/a     | yes |
| description      | description about secuirty group| `string` | ``    | no |
| ingress_rules    | traffic inbout rules         | `list(object())` | `[]`    | yes |
| egress_rules     | traffic outbout rules        | `list(object())` | `[]`    | yes |


## Outputs
