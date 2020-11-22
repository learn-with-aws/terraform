# EIP
resource "aws_eip" "gateway-nat-ip" {
  vpc = "true"
}

# NAT Gateway
resource "aws_nat_gateway" "gateway-nat" {
  allocation_id = aws_eip.gateway-nat-ip.id
  subnet_id = aws_subnet.gateway-pub-subnet-1a.id
  depends_on = [aws_internet_gateway.gateway-ig]
  tags = {
    Name = "gateway-NAT"
  }
}

# private Route Table
resource "aws_route_table" "gateway-pri-main" {
  vpc_id = aws_vpc.gateway-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gateway-nat.id
  }
  tags = {
    Name = "gateway-pri-main"
  }
}

# Assosiate to Route Table
resource "aws_route_table_association" "rt-pri-1a" {
  route_table_id = aws_route_table.gateway-pri-main.id
  subnet_id = aws_subnet.gateway-pri-subnet-1a.id
}
resource "aws_route_table_association" "rt-pri-1b" {
  route_table_id = aws_route_table.gateway-pri-main.id
  subnet_id = aws_subnet.gateway-pri-subnet-1b.id
}
resource "aws_route_table_association" "rt-pri-1c" {
  route_table_id = aws_route_table.gateway-pri-main.id
  subnet_id = aws_subnet.gateway-pri-subnet-1c.id
}