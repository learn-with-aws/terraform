resource "aws_security_group" "gateway-pub-sg" {
  name = "gateway-pub-sg"
  description = "For gateway Public Subnets"
  vpc_id = aws_vpc.gateway-vpc.id
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
    Name = "gateway-pub-sg"
  }
}

resource "aws_security_group" "gateway-pri-sg" {
  name = "gateway-pri-sg"
  description = "For Gateway Private Subnet"
  vpc_id = aws_vpc.gateway-vpc.id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    security_groups = [aws_security_group.gateway-pub-sg.id]
  }
  ingress {
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
    security_groups = [aws_security_group.gateway-pub-sg.id]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "gateway-pri-sg"
  }
}