data "aws_availability_zones" "available" {}

locals {
  subnets = tolist([
    for index in range(length(data.aws_availability_zones.available.names) * 2) :
    cidrsubnet(var.aws_vpc_cidr, var.aws_subnet_newbits, index)
  ])
}

resource "aws_vpc" "vpc" {
  cidr_block       = var.aws_vpc_cidr
  instance_tenancy = var.aws_vpc_tenancy
  tags = merge(
    { Name = var.aws_vpc_name },
    var.aws_vpc_tags
  )
}

resource "aws_subnet" "public" {
  for_each                = toset(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value
  cidr_block              = slice(local.subnets, 0, length(data.aws_availability_zones.available.names))[index(tolist(data.aws_availability_zones.available.names), each.value)]
  map_public_ip_on_launch = true
  tags = merge(
    { Name = format("%s-%s-%s", var.aws_vpc_name, "public", each.value), Tier = "public" },
    var.aws_vpc_tags
  )
}

resource "aws_subnet" "private" {
  for_each          = toset(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value
  cidr_block        = slice(local.subnets, ceil((length(data.aws_availability_zones.available.names) / 2) + 1), length(data.aws_availability_zones.available.names) * 2)[index(tolist(data.aws_availability_zones.available.names), each.value)]
  tags = merge(
    { Name = format("%s-%s-%s", var.aws_vpc_name, "private", each.value), Tier = "private" },
    var.aws_vpc_tags
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    { Name = format("%s_%s", var.aws_vpc_name, "igw") },
    var.aws_vpc_tags
  )
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  dynamic "route" {
    for_each = var.aws_route_table_additional_routes
    content {
      cidr_block = route.value["cidr_block"]
      gateway_id = route.value["gateway_id"]
    }
  }

  tags = merge(
    { Name = format("%s_%s", var.aws_vpc_name, "public_rtb") },
    var.aws_vpc_tags
  )
}

resource "aws_route_table_association" "d4rkness_cloud_route_to_public_subnet" {
  for_each       = toset(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.public[each.value].id
  route_table_id = aws_route_table.rt.id
}
