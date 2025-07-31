## define IGW and route table for public subnets ##

# resource "aws_internet_gateway" "main-igw" {
#     vpc_id = aws_vpc.main_vpc.id
#     tags = {
#       Name = "${var.env_deploy}-igw"
#       ENV = var.env_deploy
#     }
# }

# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main_vpc.id
#   tags = {
#     Name = "${var.env_deploy}-public-rt"
#   }
# }

# resource "aws_route_table_association" "public" {
#   for_each = aws_subnet.public  
#   subnet_id = each.value.id
#   route_table_id = aws_route_table.public.id
# }

# resource "aws_route" "public-to-igw" {
#   route_table_id = aws_route_table.public.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id = aws_internet_gateway.main-igw.id
# }

## define NAT-GW and route table for private subnets need Internet##

# resource "aws_eip" "eip-nat" {
#   domain = "vpc"  
# }

# resource "aws_nat_gateway" "nat_gw" {
#   allocation_id = aws_eip.eip-nat.id
#   subnet_id = aws_subnet.public[0].id
#   tags = {
#     Name = "${var.env_deploy}-nat-gw"
#   }
# }

# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main_vpc.id
#   tags = {
#     Name = "${var.env_deploy}-private-rt"
#   }
# }

# resource "aws_route_table_association" "private" {
#   count = length(aws_subnet.services_subnets)
#   subnet_id = aws_subnet.services_subnets[count.index].id
#   route_table_id = aws_route_table.private.id
# }

# resource "aws_route" "private" {
#   route_table_id = aws_route_table.private.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id = aws_nat_gateway.nat_gw.id
# }