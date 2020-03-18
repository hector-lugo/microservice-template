resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true

  tags = merge(
    {
      "Name" = format("%s-vpc", var.prefix)
    },
    var.tags
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      "Name" = format("%s-igw", var.prefix)
    },
    var.tags
  )
}

resource "aws_subnet" "public_subnets" {
  count = length(var.vpc_public_subnets)

  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.vpc_public_subnets, count.index)
  availability_zone = element(var.vpc_availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = format("%s_public_subnet_%s", var.prefix, count.index)
    },
    var.tags
  )
}

resource "aws_subnet" "private_subnets" {
  count = length(var.vpc_private_subnets)

  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.vpc_private_subnets, count.index)
  availability_zone = element(var.vpc_availability_zones, count.index)

  tags = merge(
    {
      "Name" = format("%s_private_subnets_%s", var.prefix, count.index)
    },
    var.tags
  )
}

resource "aws_eip" "elastic_ips" {
  count = length(var.vpc_availability_zones)

  vpc = true

  tags = merge(
    {
      "Name" = format("%s_eip_%s", var.prefix, count.index)
    },
    var.tags
  )
}

resource "aws_nat_gateway" "nat_gateways" {
  count = length(var.vpc_availability_zones)

  allocation_id = element(
    aws_eip.elastic_ips.*.id,
    count.index,
  )

  subnet_id = element(
    aws_subnet.public_subnets.*.id,
    count.index,
  )

  tags = merge(
    {
      "Name" = format("%s_natg_%s", var.prefix, count.index)
    },
    var.tags
  )
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      "Name" = format("%s_public_rt", var.prefix)
    },
    var.tags
  )
}

resource "aws_route_table_association" "public_route_table_associations" {
  count = length(var.vpc_public_subnets)

  route_table_id = aws_route_table.public_rt.id

  subnet_id = element(
    aws_subnet.public_subnets.*.id,
    count.index,
  )
}

resource "aws_route_table" "private_route_tables" {
  count = length(var.vpc_availability_zones)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.nat_gateways.*.id, count.index)
  }

  tags = merge(
    {
      "Name" = format("%s_private_rt_%s", var.prefix, count.index)
    },
    var.tags
  )
}

resource "aws_route_table_association" "private_rt_association_1" {
  count = length(var.vpc_private_subnets)

  route_table_id = element(aws_route_table.private_route_tables.*.id, count.index)
  subnet_id = element(aws_subnet.private_subnets.*.id, count.index)
}