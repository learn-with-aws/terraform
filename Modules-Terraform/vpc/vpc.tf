provider "aws" {
  region = "us-east-1"
}

module "vpc_creation" {
  source = "../modules/vpc"

  AWS_REGION    = "us-east-1"
  vpc_name      = "wildcraft"
  cidr_block    = "10.0.0.0/16"
  pub-subnet-1a = "10.0.0.0/24"
  pub-subnet-1b = "10.0.1.0/24"
  pub-subnet-1c = "10.0.2.0/24"
  pri-subnet-1a = "10.0.4.0/24"
  pri-subnet-1b = "10.0.5.0/24"
  pri-subnet-1c = "10.0.6.0/24"
}