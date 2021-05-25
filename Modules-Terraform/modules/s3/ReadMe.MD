## Usecase of S3 Module

    provider "aws" {
        region = "us-east-1"
    }

    module "s3_bucket_creation" {
        source         = "../modules/s3"
        bucket_Name    = "us-wildcraft-prod"
        visibility     = "public-read"
        environment    = "prod"
        logs_target_bucket = "anand0987-statefiles"
        logs_target_prefix = "logs/us-wildcraft-prod/"
    }

    module "s3_backend" {
        source                = "../modules/s3_backend"
        bucket_statefile_name = "anand0987-statefiles"
        path_prefix           = "s3_state_files/us-wildcraft-prod/s3.tfstate"
        region_name           = "us-east-1"            
    }