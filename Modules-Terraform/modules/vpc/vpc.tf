# VPC Main
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = "true"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_classiclink = "false"
  tags = {
    Name = "${var.vpc_name}-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "vpc-pub-subnet-1a" {
  cidr_block = var.pub-subnet-1a
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
  availability_zone = "${var.AWS_REGION}a"
  tags = {
    Name = "${var.vpc_name}-pub-subnet-1a"
  }
}
resource "aws_subnet" "vpc-pub-subnet-1b" {
  cidr_block = var.pub-subnet-1b
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
  availability_zone = "${var.AWS_REGION}b"
  tags = {
    Name = "${var.vpc_name}-pub-subnet-1b"
  }
}
resource "aws_subnet" "vpc-pub-subnet-1c" {
  cidr_block = var.pub-subnet-1c
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
  availability_zone = "${var.AWS_REGION}c"
  tags = {
    Name = "${var.vpc_name}-pub-subnet-1c"
  }
}

# Private Subnets
resource "aws_subnet" "vpc-pri-subnet-1a" {
  cidr_block = var.pri-subnet-1a
  vpc_id = aws_vpc.vpc.id
  availability_zone = "${var.AWS_REGION}a"
  tags = {
    Name = "${var.vpc_name}-pri-subnet-1a"
  }
}
resource "aws_subnet" "vpc-pri-subnet-1b" {
  cidr_block = var.pri-subnet-1b
  vpc_id = aws_vpc.vpc.id
  availability_zone = "${var.AWS_REGION}b"
  tags = {
    Name = "${var.vpc_name}-pri-subnet-1b"
  }
}
resource "aws_subnet" "vpc-pri-subnet-1c" {
  cidr_block = var.pri-subnet-1c
  vpc_id = aws_vpc.vpc.id
  availability_zone = "${var.AWS_REGION}c"
  tags = {
    Name = "${var.vpc_name}-pri-subnet-1c"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "vpc-ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-ig"
  }
}

# Public Route Table
resource "aws_route_table" "vpc-main-routetable" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-ig.id
  }
  tags = {
    Name ="${var.vpc_name}-pub-rt"
  }
}

# Assosiate subnets with Route Table
resource "aws_route_table_association" "rt-pub-1a" {
  subnet_id = aws_subnet.vpc-pub-subnet-1a.id
  route_table_id = aws_route_table.vpc-main-routetable.id
}
resource "aws_route_table_association" "rt-pub-1b" {
  subnet_id = aws_subnet.vpc-pub-subnet-1b.id
  route_table_id = aws_route_table.vpc-main-routetable.id
}
resource "aws_route_table_association" "rt-pub-1c" {
  subnet_id = aws_subnet.vpc-pub-subnet-1c.id
  route_table_id = aws_route_table.vpc-main-routetable.id
}


## NAT Gateways

# EIP
resource "aws_eip" "vpc_nat_ip" {
  vpc = "true"
  tags = {
    Name = "${var.vpc_name}-EIP"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "vpc-nat" {
  allocation_id = aws_eip.vpc_nat_ip.id
  subnet_id = aws_subnet.vpc-pub-subnet-1a.id
  depends_on = [aws_internet_gateway.vpc-ig]
  tags = {
    Name = "${var.vpc_name}-NAT"
  }
}

# private Route Table
resource "aws_route_table" "vpc-pri-main" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.vpc-nat.id
  }
  tags = {
    Name = "${var.vpc_name}-pri-rt"
  }
}

# Assosiate to Route Table
resource "aws_route_table_association" "rt-pri-1a" {
  route_table_id = aws_route_table.vpc-pri-main.id
  subnet_id = aws_subnet.vpc-pri-subnet-1a.id
}
resource "aws_route_table_association" "rt-pri-1b" {
  route_table_id = aws_route_table.vpc-pri-main.id
  subnet_id = aws_subnet.vpc-pri-subnet-1b.id
}
resource "aws_route_table_association" "rt-pri-1c" {
  route_table_id = aws_route_table.vpc-pri-main.id
  subnet_id = aws_subnet.vpc-pri-subnet-1c.id
}

# Security Groups

resource "aws_security_group" "vpc-pub-sg" {
  name = "${var.vpc_name}-pub-sg"
  description = "For ${var.vpc_name} Public Subnets"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.vpc_name}-pub-sg"
  }
}

resource "aws_security_group" "vpc-pri-sg" {
  name = "${var.vpc_name}-pri-sg"
  description = "For ${var.vpc_name} Private Subnet"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    security_groups = [aws_security_group.vpc-pub-sg.id]
  }
  ingress {
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
    security_groups = [aws_security_group.vpc-pub-sg.id]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.vpc_name}-pri-sg"
  }
}