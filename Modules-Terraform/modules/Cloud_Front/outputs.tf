output "S3_Bucket_ID" {
  value = aws_s3_bucket.s3_bucket.id
}

output "S3_bucket_domain_name" {
    value = aws_s3_bucket.s3_bucket.bucket_domain_name
}

output "S3" {
    value = aws_s3_bucket.s3_bucket.bucket_prefix
}