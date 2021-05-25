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

terraform {
    backend "s3" {
        bucket = "anand0987-statefiles"
        key    = "s3_state_files/us-wildcraft-prod/s3.tfstate"
        region = "us-east-1"
    }
}