terraform {
  required_version = ">=0.15"
}

resource "aws_s3_bucket" "wildcraft" {
  bucket = var.bucket_Name
  acl    = var.visibility

  versioning {
    enabled = var.versioning
  }

  website {
      index_document = var.success_page
      error_document = var.error_Page
  }

  logging {
      target_bucket = var.logs_target_bucket
      target_prefix = var.logs_target_prefix
  }

#   lifecycle {
#     prevent_destroy = true
#   }

  force_destroy = true

  tags = {
      Name        = var.bucket_Name
      Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "wildcraft" {
    bucket = aws_s3_bucket.wildcraft.id

    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.wildcraft.id}/*"
            ]
        }
    ]
}
POLICY
  
}