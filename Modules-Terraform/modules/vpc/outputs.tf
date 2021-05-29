output "vpc_id" {
    description = "The VPC Id is"
    value = "${aws_vpc.vpc.id}"
}

output "aws_internet_gateway" {
    description = "Internet Gateway id Is"
    value = "${aws_internet_gateway.vpc-ig.id}"
}