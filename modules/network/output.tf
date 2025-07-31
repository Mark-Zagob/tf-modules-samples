# output "subnet_service_name" {
#   value = local.subnet_service_name
# }

output "vpc_id" {
    value = aws_vpc.main_vpc.id
}

output "services_subnets_ids" {
    value = { for k,s in aws_subnet.services_subnets : k => s.id }
}

output "intra_subnets_ids" {
  value = { for k,s in aws_subnet.intra_subnet : k => s.id }
}