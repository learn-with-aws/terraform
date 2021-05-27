## Terraform

### Terraform import existing infrastructure details.

    Syntax : 
    
        terraform import <resource_type>.<resource_name> <resource_id>z
        
    Example :  
      
        terraform import aws_s3_bucket.examplebucket anand0987uio
    
    
### USe Multiple AWS accounts with single module

You can configure multiple providers ( one per account in your case) and create an alias for each. Then you will need to specify the provider for each ressource. Example:

    provider "aws" {
      region  = "eu-west-1"
      profile = "profile1"
      alias   = "account1"
    }

    provider "aws" {
      region  = "eu-west-1"
      profile = "profile2"
      alias   = "account2"
    }

    resource "aws_lambda_function" "function1" {
      provider = "aws.account1" // will be created in account 1
      ...
    }
    resource "aws_lambda_function" "function2" {
      provider = "aws.account2" // will be created in account 2
      ...
    }
