output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnets" {
  value = {
    for zone in data.aws_availability_zones.available.names: 
      zone => aws_subnet.private[zone].id
  }
}

output "public_subnets" {
  value = {
    for zone in data.aws_availability_zones.available.names: 
      zone => aws_subnet.public[zone].id
  }
}