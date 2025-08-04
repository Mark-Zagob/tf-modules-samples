## define IGW and route table for public subnets ##

resource "aws_internet_gateway" "main-igw" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {
      Name = "${var.env_deploy}-igw"
      ENV = var.env_deploy
    }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.env_deploy}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public  
  subnet_id = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public-to-igw" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main-igw.id
}

## define NAT-GW and route table for private subnets need Internet##
## base on value of natgw variables defined
locals {
  nat_gw_count = ( !var.enable_natgw ? 0 : 
                        var.enable_natgw && !var.natgw_per_az ? 1: 
                            length(var.avai_zones) )
  natgw_azs = (
    local.nat_gw_count == 0 ? [] : 
        local.nat_gw_count == 1 ? [var.avai_zones[0]] : 
            var.avai_zones
  )
}

#eip for nat gw#
resource "aws_eip" "nat_eip" {
  for_each = toset(local.natgw_azs)
  
  domain = "vpc"
  tags = {
    Name = "${var.env_deploy}-nat-eip-${substr(each.value, length(each.value)-2, 2)}"
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_nat_gateway" "nat" {
  for_each = toset(local.natgw_azs)

  allocation_id = aws_eip.nat_eip[each.value].id
  subnet_id     = aws_subnet.public[index(var.avai_zones, each.value)].id
  tags = {
    Name = "${var.env_deploy}-nat-${substr(each.value, length(each.value)-2, 2)}"
  }

  depends_on = [aws_internet_gateway.main-igw]
}

resource "aws_route_table" "private" {
    for_each = toset(local.natgw_azs)
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "${var.env_deploy}-private-rt-${substr(each.value, length(each.value)-2, 2)}"
    }
}

resource "aws_route_table_association" "private_services" {
  for_each = aws_subnet.services_subnets

  subnet_id = each.value.id
  route_table_id = aws_route_table.private[each.value.availability_zone].id
}


resource "aws_route" "private" {
  for_each = var.enable_natgw ? aws_route_table.private : {}
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = (
    local.nat_gw_count == 1 ? aws_nat_gateway.nat[local.natgw_azs[0]].id : 
    aws_nat_gateway.nat[each.key].id
  )
}