resource "aws_s3_bucket" "gateway_buckets_dev"{
    bucket  = var.Bucket_Name
    acl     = var.Visibility

    versioning {
        enabled = true
    }

    force_destroy = true

    tags = {
        Name        = "gateway_apache_logs"
        Environment = "Dev"
    }
}