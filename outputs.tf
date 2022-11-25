output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnets" {
  value = {
    for zone in data.aws_availability_zones.available.names :
    zone => {
      "id"   = aws_subnet.private[zone].id
      "cidr" = aws_subnet.private[zone].cidr_block
    }
  }
}

output "public_subnets" {
  value = {
    for zone in data.aws_availability_zones.available.names :
    zone => {
      "id"   = aws_subnet.public[zone].id
      "cidr" = aws_subnet.public[zone].cidr_block
    }
  }
}

output "nat_gateway_ip" {
  value = values(aws_eip.nat_gateway).*.public_ip
}