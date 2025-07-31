## Define main vpc and subnet for services types ##
## split services for subnets ##

# version 1#
# locals {
#   private_subnets_list = flatten([
#     for service_subnet in var.services_subnets : [
#         for az in var.avai_zones : {
#             name = "${service_subnet}-${substr(az,length(az)-2,2)}"
#             az = "${az}"
#         }
#     ]
#   ])
#   intra_subnets_list = flatten([
#     for intra_subnet in var.intra_subnets : [
#       for az in var.avai_zones : {
#         name = "${intra_subnet}-${substr(az,length(az)-2,2)}"
#         az = "${az}"
#       }
#     ]
#   ]
#   )
# }

#version 2#
locals {
  # Tạo map ổn định cho các subnet
  private_subnets_map = {
    for combo in setproduct(var.services_subnets, var.avai_zones) : 
    "${combo[0]}-${substr(combo[1], length(combo[1])-2, 2)}" => {
      name = combo[0]
      az   = combo[1]
      # Tính toán CIDR index độc lập với thứ tự
      cidr_index = index(var.services_subnets, combo[0]) * length(var.avai_zones) + index(var.avai_zones, combo[1])
    }
  }

  intra_subnets_map = {
    for combo in setproduct(var.intra_subnets, var.avai_zones) : 
    "${combo[0]}-${substr(combo[1], length(combo[1])-2, 2)}" => {
      name = combo[0]
      az   = combo[1]
      cidr_index = index(var.intra_subnets, combo[0]) * length(var.avai_zones) + index(var.avai_zones, combo[1])
    }
  }
}

## Define main vpc ##

resource "aws_vpc" "main_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = merge({
      Name = "${var.env_deploy}-main-vpc"
    }, var.tags)
}

## Define hardcode subnet for management ##

resource "aws_subnet" "management" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.mgmt_subnet
    availability_zone = var.avai_zones[0]
    tags = {
      Name = "${var.env_deploy}-mgmt-subnet"
      Tier = "Management"
      ENV = var.env_deploy
    }
}


## Define public subnets ##

resource "aws_subnet" "public" {
  for_each = {
    for idx, val in var.avai_zones : idx => val
  }
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 6, each.key)
    availability_zone = each.value
    tags = {
      Name = "${var.env_deploy}-public-subnet-${each.key+1}"
      Tier = "Public"
      ENV = var.env_deploy
    }
}


## Define dynamic private internet subnets for services ##

# version 1#
# resource "aws_subnet" "services_subnets" {
#     count = length(local.private_subnets_list)
#     vpc_id = aws_vpc.main_vpc.id
#     cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 14)
#     availability_zone = element(local.private_subnets_list, count.index).az
#     tags = {
#       Name = "${var.env_deploy}-subnet-${local.private_subnets_list[count.index].name}"
#       Tier = "${local.private_subnets_list[count.index].name}"
#       ENV = var.env_deploy
#     }
# }

#version 2#
resource "aws_subnet" "services_subnets" {
  for_each = local.private_subnets_map

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value.cidr_index + 14)
  availability_zone = each.value.az
  tags = {
    Name = "${var.env_deploy}-subnet-${each.key}"
    Tier = each.value.name
    ENV  = var.env_deploy
  }
}

## Define dynamic private intranet subnets for services ##

#version 1#
# resource "aws_subnet" "intra_subnet" {
#     count = length(local.intra_subnets_list)
#     vpc_id = aws_vpc.main_vpc.id
#     cidr_block = cidrsubnet(var.vpc_cidr, 10, count.index + 1000 )
#     availability_zone = element(local.intra_subnets_list, count.index).az
#     tags = {
#       Name = "${var.env_deploy}-subnet-${local.intra_subnets_list[count.index].name}"
#       Tier = "${local.intra_subnets_list[count.index].name}"
#       ENV = var.env_deploy
#     }
# }

#version 2#
resource "aws_subnet" "intra_subnet" {
  for_each = local.intra_subnets_map

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 10, each.value.cidr_index + 1000)
  availability_zone = each.value.az
  tags = {
    Name = "${var.env_deploy}-subnet-${each.key}"
    Tier = each.value.name
    ENV  = var.env_deploy
  }
}

## filter subnets id by name to reuse ##
# locals {
#   subnet_service_name = {
#     for private_subnet in var.services_subnets:
#     private_subnet => [
#         for subnet in aws_subnet.services_subnets : 
#         subnet.id if can(regex(".*${private_subnet}.*", subnet.tags["Name"]))
#     ]
#   }
# }

# output "subnet_service_name" {
#   value = local.subnet_service_name
# }
