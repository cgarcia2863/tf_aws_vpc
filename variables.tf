variable "aws_vpc_name" {
  type = string
}

variable "aws_vpc_tags" {
  type    = map(any)
  default = {}
}

variable "aws_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "aws_vpc_tenancy" {
  type    = string
  default = "default"
}

variable "aws_subnet_newbits" {
  type    = number
  default = 8
}

variable "aws_route_table_additional_routes" {
  type    = list(map(any))
  default = []
}

variable "aws_route_table_additional_ngw_routes" {
  type    = list(map(any))
  default = []
}

variable "aws_nat_gateway_deploy" {
  type    = bool
  default = false
}