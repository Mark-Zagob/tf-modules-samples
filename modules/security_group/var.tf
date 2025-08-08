variable "vpc_id" {
    type = string
}

variable "name" {
  type = string
  description = "Name of the security group"  
}

variable "description" {
  type = string
  description = "description of the security group"  
  default = ""
}


variable "env_deploy" {
  type = string  
}

variable "ingress_rules" {
  type = list(object({
    description     = optional(string, "Ingress rule")
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string), [])
    prefix_list_ids = optional(list(string), [])
    security_groups = optional(list(string), [])
    self            = optional(bool, false)
  }))
  default     = []
  description = "List of ingress rules to create"
}

variable "egress_rules" {
  type = list(object({
    description     = optional(string, "Egress rule")
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string), [])
    prefix_list_ids = optional(list(string), [])
    security_groups = optional(list(string), [])
    self            = optional(bool, false)
  }))
  default     = []
  description = "List of egress rules to create"
}