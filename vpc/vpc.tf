# VPC Main
resource "aws_vpc" "gateway-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_classiclink = "false"
  tags = {
    Name = "gateway-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "gateway-pub-subnet-1a" {
  cidr_block = "10.0.0.0/24"
  vpc_id = aws_vpc.gateway-vpc.id
  map_public_ip_on_launch = "true"
  availability_zone = "${var.region_subnet_name}a"
  tags = {
    Name = "gateway-pub-subnet-1a"
  }
}
resource "aws_subnet" "gateway-pub-subnet-1b" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.gateway-vpc.id
  map_public_ip_on_launch = "true"
  availability_zone = "${var.region_subnet_name}b"
  tags = {
    Name = "gateway-pub-subnet-1b"
  }
}
resource "aws_subnet" "gateway-pub-subnet-1c" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.gateway-vpc.id
  map_public_ip_on_launch = "true"
  availability_zone = "${var.region_subnet_name}c"
  tags = {
    Name = "gateway-pub-subnet-1c"
  }
}

# Private Subnets
resource "aws_subnet" "gateway-pri-subnet-1a" {
  cidr_block = "10.0.4.0/24"
  vpc_id = aws_vpc.gateway-vpc.id
  availability_zone = "${var.region_subnet_name}a"
  tags = {
    Name = "gateway-pri-subnet-1a"
  }
}
resource "aws_subnet" "gateway-pri-subnet-1b" {
  cidr_block = "10.0.5.0/24"
  vpc_id = aws_vpc.gateway-vpc.id
  availability_zone = "${var.region_subnet_name}b"
  tags = {
    Name = "gateway-pri-subnet-1b"
  }
}
resource "aws_subnet" "gateway-pri-subnet-1c" {
  cidr_block = "10.0.6.0/24"
  vpc_id = aws_vpc.gateway-vpc.id
  availability_zone = "${var.region_subnet_name}c"
  tags = {
    Name = "gateway-pri-subnet-1c"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gateway-ig" {
  vpc_id = aws_vpc.gateway-vpc.id
  tags = {
    Name = "gateway-ig"
  }
}

# Public Route Table
resource "aws_route_table" "gateway-main-routetable" {
  vpc_id = aws_vpc.gateway-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway-ig.id
  }
  tags = {
    Name ="gateway-pub-routetable"
  }
}

# Assosiate subnets with Route Table
resource "aws_route_table_association" "rt-pub-1a" {
  subnet_id = aws_subnet.gateway-pub-subnet-1a.id
  route_table_id = aws_route_table.gateway-main-routetable.id
}
resource "aws_route_table_association" "rt-pub-1b" {
  subnet_id = aws_subnet.gateway-pub-subnet-1b.id
  route_table_id = aws_route_table.gateway-main-routetable.id
}
resource "aws_route_table_association" "rt-pub-1c" {
  subnet_id = aws_subnet.gateway-pub-subnet-1c.id
  route_table_id = aws_route_table.gateway-main-routetable.id
}

terraform {
 backend “s3” {
 bucket = "terraform-remote-state-storage-s3-vpc"
 region = "us-east-1"
 key = "vpc/terraform.tfstate"
 }
}

