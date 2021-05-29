## Terraform

### Terraform import existing infrastructure details.

    Syntax : 
    
        terraform import <resource_type>.<resource_name> <resource_id>z
        
    Example :  
      
        terraform import aws_s3_bucket.examplebucket anand0987uio
    
    
### USe Multiple AWS accounts with single module

Solution 1:  ( with Alias names )

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


Solution 2:- ( With workspace )

Note : This are like Github branches

- Create a workspace 

        terraform workspace new production

- Switch the workspace

        terraform workspace select production

                provider "aws" {
                  region= "us-east-1"
                }
                locals {
                  env="${terraform.workspace}"
                  counts = {
                    "default"=1
                    "production"=3
                  }
                  instances = {
                    "default"="t2.micro"
                    "production"="t4.large"
                  }
                  instance_type="${lookup(local.instances,local.env)}"
                  count="${lookup(local.counts,local.env)}"
                }
                resource "aws_instance" "my_service" {
                  ami="ami-7b4d7900"
                  instance_type="${local.instance_type}"
                  count="${local.count}"
                }
                
 
Solution 3 : 

   Terraform Assume Role
   
            We will instantiate the team-account-roles module once per team account. In order to run the full project with only the credentials from the Identity account, we will use Terraform’s assume role function.


### Take OutPut from one module and use it in different module.


        In your kafka module, you could define an output that looks something like this:


        output "instance_ids" {
          value = ["${aws_instance.kafka.*.id}"]
        }
        Case 1 – If you are calling kafka module from cloudwatch module by instantiated the module with something like:



        module "kafka" {
          source = "./modules/kafka"
        }

        # You can then access that output as follows:
        instances = ["${module.kafka.instance_ids}"]