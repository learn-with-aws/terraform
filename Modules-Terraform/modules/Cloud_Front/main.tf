terraform {
  required_version = ">=0.15"
}

resource "aws_s3_bucket" "s3_bucket" {
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

  force_destroy = var.force_destroy

  tags = {
      Name        = var.bucket_Name
      Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "s3_bucket" {
    bucket = aws_s3_bucket.s3_bucket.id

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
                "arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}/*"
            ]
        }
    ]
}
POLICY
}

locals {
  s3_origin_id = var.bucket_Name
}

resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
        domain_name     = "${aws_s3_bucket.s3_bucket.bucket_regional_domain_name}"
        origin_id       = "${local.s3_origin_id}"
    }

    enabled             = true
    is_ipv6_enabled     = true
    comment             = var.comment
    default_root_object = "${var.success_page}"
    price_class         = "PriceClass_200"

    tags = {
        Environment     = "Production"
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }

    default_cache_behavior {
        allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "${local.s3_origin_id}"

        forwarded_values {
          query_string   = false

          cookies {
            forward      = "none"
          }
        }

        viewer_protocol_policy = "allow-all"
        min_ttl          = 0
        default_ttl      = 3600
        max_ttl          = 86400
    }

    restrictions {
        geo_restriction {
            restriction_type = var.geo_restriction_type
            locations        = var.geo_restriction_locations
            # restriction_type = "whitelist"
            # locations        = ["US", "CA", "GB", "DE"]
        }
    }
}