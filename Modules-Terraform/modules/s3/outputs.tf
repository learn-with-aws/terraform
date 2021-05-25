output "S3_Bucket_ID" {
  value = aws_s3_bucket.wildcraft.id
}

output "S3_bucket_domain_name" {
    value = aws_s3_bucket.wildcraft.bucket_domain_name
}

output "S3" {
    value = aws_s3_bucket.wildcraft.bucket_prefix
}