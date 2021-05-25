terraform {
    backend "s3" {
        bucket = var.bucket_statefile_name
        key    = var.path_prefix
        region = var.region_name
    }
}