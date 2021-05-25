provider "aws" {
    region = "us-east-1"
}

locals {
    bucket_Name = "us-cloudfront1-prod"
}

module "aws_cloud_front" {
    source         = "../modules/Cloud_Front"

    bucket_Name    = local.bucket_Name
    visibility     = "public-read"
    environment    = "prod"
    logs_target_bucket = "anand0987-statefiles"
    logs_target_prefix = "logs/${local.bucket_Name}/"
    
}

module "s3_backend" {
    source                = "../modules/s3_backend"
    bucket_statefile_name = "anand0987-statefiles"
    path_prefix           = "s3_state_files/${local.bucket_Name}/s3.tfstate"
    region_name           = "us-east-1"            
}