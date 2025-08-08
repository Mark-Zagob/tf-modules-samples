resource "aws_security_group" "this" {
    name = var.name
    vpc_id = var.vpc_id
    description = var.description
    tags = {
        Name = var.name
        Tier = "Security"
        ENV = var.env_deploy
      }
    lifecycle {
        create_before_destroy = true
    }
}

# Dynamic ingress rules
resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }

  security_group_id = aws_security_group.this.id
  type              = "ingress"

  description      = each.value.description
  from_port        = each.value.from_port
  to_port          = each.value.to_port
  protocol         = each.value.protocol
  cidr_blocks      = each.value.self ? null : each.value.cidr_blocks
  ipv6_cidr_blocks = each.value.self ? null : each.value.ipv6_cidr_blocks
  prefix_list_ids  = each.value.self ? null : each.value.prefix_list_ids
  self             = each.value.self ? true : null
  
  # Xử lý riêng security groups reference
  source_security_group_id = length(coalesce(each.value.security_groups, [])) > 0 ? each.value.security_groups[0] : null
}

# Dynamic egress rules with default allow all
resource "aws_security_group_rule" "egress" {
  for_each = { for idx, rule in var.egress_rules : idx => rule }

  security_group_id = aws_security_group.this.id
  type              = "egress"

  description      = try(each.value.description, "Allow all outbound traffic")
  from_port        = try(each.value.from_port, 0)
  to_port          = try(each.value.to_port, 0)
  protocol         = try(each.value.protocol, "-1")
  cidr_blocks      = try(each.value.self, false) ? null : (try(each.value.cidr_blocks, length(var.egress_rules) > 0 ? [] : ["0.0.0.0/0"]))
  ipv6_cidr_blocks = try(each.value.self, false) ? null : (try(each.value.ipv6_cidr_blocks, length(var.egress_rules) > 0 ? [] : ["::/0"]))
  prefix_list_ids  = try(each.value.self, false) ? null : try(each.value.prefix_list_ids, [])
  self             = try(each.value.self, false) ? true : null
  
  # Xử lý riêng security groups reference
  source_security_group_id = length(try(each.value.security_groups, [])) > 0 ? each.value.security_groups[0] : null
}