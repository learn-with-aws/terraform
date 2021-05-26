## Usese of CloudFront Module


### Use this module like below 

    provider "aws" {
        region = "us-east-1"
    }

    locals {
        bucket_Name = "us-cloudfront1-dev"
    }

    module "aws_cloud_front" {
        source         = "../../modules/Cloud_Front"

        bucket_Name    = local.bucket_Name
        visibility     = "public-read"
        environment    = "dev"
        logs_target_bucket = "anand0987-statefiles"
        logs_target_prefix = "logs/${local.bucket_Name}/"
        
    }

    module "s3_backend" {
        source                = "../../modules/s3_backend"
        bucket_statefile_name = "anand0987-statefiles"
        path_prefix           = "s3_state_files/${local.bucket_Name}/s3.tfstate"
        region_name           = "us-east-1"            
    }


    ## Cloud Front invalidation

    Refe Page : https://blog.miguelangelnieto.net/posts/Automatic_Cloudfront_invalidation_with_Amazon_Lambda.html


    Step 1:  Create a Blank AWS Lambda 
    Step 2:  select S3 as a trigger point and select bucket and event type.
    Step 3:  Add below code as python 2.7

    from __future__ import print_function

            import boto3
            import time

            def lambda_handler(event, context):
                path = []
                for items in event["Records"]:
                    if items["s3"]["object"]["key"] == "index.html":
                        path.append("/")
                    else:
                        path.append("/" + items["s3"]["object"]["key"])
                print(path)
                client = boto3.client('cloudfront')
                invalidation = client.create_invalidation(DistributionId='E8F6HK73EP0LT',
                    InvalidationBatch={
                        'Paths': {
                            'Quantity': 1,
                            'Items': path
                    },
                    'CallerReference': str(time.time())
                })

    step 4: Create a role and attach below policy to that role

                {
                "Version": "2012-10-17",
                "Statement": [
                    {
                    "Effect": "Allow",
                    "Action": [
                        "logs:CreateLogGroup",
                        "logs:CreateLogStream",
                        "logs:PutLogEvents"
                    ],
                    "Resource": "arn:aws:logs:*:*:*"
                    },
                    {
                        "Effect": "Allow",
                        "Action": [
                            "cloudfront:CreateInvalidation"
                        ],
                        "Resource": [
                            "*"
                        ]
                    }
                ]
                }
    Step 5 : Try to modify a file and push to S3 bucket. Automatically Invalidation will be create.