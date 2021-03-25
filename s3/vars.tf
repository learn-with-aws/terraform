variable "REGION" {
    default = "us-east-1"
}

variable "Bucket_Name" {
//    default = "gateway-apache-logs-dev"
}

variable "Visibility" {
//    default = "private"
}

terraform{
  backend "s3"{
    bucket = "anand-terraform-logs"
    key = "s3/dev/terraform.tfstate"
    region = "us-east-1"
  }
}

// Pass the arguments like this.
//terraform apply -var "Bucket_Name=gateway-apache-logs-dev" -var "Visibility=private"