data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.project_name
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet1_cidr
  availability_zone       = var.region_az1
  map_public_ip_on_launch = true
  tags = {
    Name = var.project_name
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = var.region_az2
  map_public_ip_on_launch = true
  tags = {
    Name = var.project_name
  }
}

resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet1_cidr
  availability_zone       = var.region_az1
  map_public_ip_on_launch = false
  tags = {
    Name = var.project_name
  }
}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet2_cidr
  availability_zone       = var.region_az2
  map_public_ip_on_launch = false
  tags = {
    Name = var.project_name
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.project_name
  }
}

resource "aws_eip" "eip1" {
  vpc = true
  tags = {
    Name = var.project_name
  }
}

resource "aws_eip" "eip2" {
  vpc = true
  tags = {
    Name = var.project_name
  }
}

resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public1.id
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name = var.project_name
  }
}

resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public2.id
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name = var.project_name
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  tags = {
    Name = var.project_name
  }
}

resource "aws_route_table_association" "public_route_assoc1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "public_route_assoc2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table" "private_route1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw1.id
  }
  tags = {
    Name = var.project_name
  }
}

resource "aws_route_table_association" "private_route_assoc1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_route1.id
}

resource "aws_route_table" "private_route2" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw2.id
  }
  tags = {
    Name = var.project_name
  }
}

resource "aws_route_table_association" "private_route_assoc2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private_route2.id
}
