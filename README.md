# Terraform Interview Questions

## Variable validations.

        variable "api_key" {
          type        = string
          sensitive   = true
          validation {
            condition     = var.api_key != ""
            condition     = length(var.api_key) <= 11
            condition     = 1 <= var.worker_nodes_per_zone && var.worker_nodes_per_zone <= 1000
            condition     = contains(["true", "false"], var.required_monitoring)
            condition     = contains(["3", "5", "10"], var.bandwidth)
            condition     = var.db_vsi_count <= 3
            condition     = contains([8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384], var.bastion_ip_count)
            error_message = "API key for IBM Cloud must be set."
          }
          validation {
            condition     = can(regex("^[A-Za-z][-0-9A-Za-z]*-$", var.prefix))
            error_message = "For the prefix value only a-z, A-Z and 0-9 are allowed."
          }
        }
        
## Data Source 

      - Data sources allow Terraform to use information defined outside of Terraform, defined by another separate Terraform configuration, or modified by functions.
      - Data sources can be used for a number of reasons; but their goal is to do something and then give you data.
      
      Example-1 : 
      
                data "aws_ami" "web" {
                  filter {
                    name   = "state"
                    values = ["available"]
                  }

                  filter {
                    name   = "tag:Component"
                    values = ["web"]
                  }

                  most_recent = true
                }

       Example-2  :
       
                data "ibm_resource_group" "res_grp" {
                  name = var.resource_group
                }
                
       Usage :

        resource_group_id = data.ibm_resource_group.res_grp.id
        
   Data Source from user input
   
                data "ibm_is_ssh_key" "ssh_key" {
                  for_each = toset(split(",", var.ssh_key_name))
                  name     = each.value
                }

                locals {
                  ssh_key_list = split(",", var.ssh_key_name)
                  ssh_key_id_list = [
                    for name in local.ssh_key_list :
                    data.ibm_is_ssh_key.ssh_key[name].id
                  ]
                }
                
## Locals

        You can use local values to simplify your Terraform configuration and avoid repetition. Local values (locals) can also help you write more readable configuration by using meaningful names rather than hard-coding values.
        
                locals {
                  lin_userdata = <<-EOUD
                        #!/bin/bash
                        curl -sL https://raw.githubusercontent.com/IBM-Cloud/ibm-cloud-developer-tools/master/linux-installer/idt-installer | bash
                        ibmcloud plugin install vpc-infrastructure     
                        EOUD    
                }
    
## Null Resource

       - The primary use-case for the null resource is as a do-nothing container for arbitrary actions taken by a provisioner.
       - A common scenario is to perform custom actions using local-exec and remote-exec when a number of resources gets created. Example of such case is introduction of a delay in resource creation.
       - The triggerdefined in your null_resourceblock defines when the script you have specified is executed. 
       
            For example:

                The null_resourcetrigger can be set to run only if a resource exists:

                id = resource.id
    

                /**
                * This null resource block is for deleting the dynamic ssh key generated via bastion server. This will execute on terraform destroy. 
                * This block is for those users who has Linux/Mac as their local machines.
                * Trigger :The triggers argument allows specifying an arbitrary set of values that, when changed, will cause the resource to be replaced.
                **/

                resource "null_resource" "delete_dynamic_ssh_key" {
                  count = lower(var.local_machine_os_type) == "windows" ? 0 : 1

                  triggers = {
                    region          = var.region
                    api_key         = var.api_key
                    prefix          = var.prefix
                    bastion_ssh_key = var.bastion_ssh_key
                  }
                  provisioner "local-exec" {
                    when    = destroy
                    command = <<EOT
                      echo 'connection success'
                      ibmcloud config --check-version=false
                      i=3
                      ibmcloud login -r ${self.triggers.region} --apikey ${self.triggers.api_key}
                      while [ $? -ne 0 ] && [ $i -gt 0 ]; do
                           i=$(( i - 1 ))
                           ibmcloud login -r ${self.triggers.region} --apikey ${self.triggers.api_key}
                      done      
                      key_id=$(ibmcloud is keys | grep ${self.triggers.prefix}${self.triggers.bastion_ssh_key} | awk '{print $1}')
                      if [ ! -z "$key_id" ]; then
                          i=3
                          ibmcloud is key-delete $key_id -f
                          while [ $? -ne 0 ] && [ $i -gt 0 ]; do
                              i=$(( i - 1 ))
                              ibmcloud is key-delete $key_id -f
                          done           
                      fi     
                      ibmcloud logout
                    EOT    
                  }
                  depends_on = [
                    ibm_is_instance.bastion,
                  ]
                }

### Terraform scripts need to be ready for the following topics.

    - S3
    - CloudFront
    - EC2
    - VPC
    - ELB
    - AutoScaling
    - RDS

Ref :  https://www.bogotobogo.com/DevOps/Terraform/

## About Terraform:

- It is An Infrastructure as a Code ( IAC )

- Terraform is a tool for developing, changing and versioning infrastructure safely and efficiently. 
Terraform can manage existing and popular service providers as well as custom in-house solutions. 
Terraform is the first multi-cloud immutable infrastructure tool that was introduced to the world by **HashiCorp**,
released three years ago, and written in **Go**. 

## Installation of terraform: 

- wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
- export PATH=/root/terraform/:$PATH (or) PATH=${PATH}:/root/terraform

## Supports

It support any kind of cloud for provisining your infrastructure.

  - AWS
  - Azure
  - GoogleCloud
  - openStack
  - VM's etc...
  
## Configuration file

It supports two kind of configuration files

  - .tf files
  - .tf.json files

  Note : Terraform will download the required plugins based on provider name specified in the configuration file. 

## SetUp with AWS 

Create a IAM user with admin access and configure in Linux/Windows/Mac Server.

  - aws configure --profile <profile_name>
    ex: aws configure --profile terraform_user.  
    
## terraform_user is created from IAM with Admin access
 
 ## Terraform Commands 
 
  - Initialize the terraform
    
        terraform init.  ( Terraform will download the required plugins based on provider name specified in the configuration file )
        
  - Validate the Code
  
        terraform validate
        
  - Arrange the terraform configuration file in proper format 
  
        terraform fmt
        
  - Run your script as DRY RUN mode.
  
        terraform plan
        
        Note : Store the dryrun mode output like below
               terraform plan -out out.terraform
        
  - Provision your script 
  
        terraform apply.      // terrafor apply --auto-approve ( for auto creating the ec2 )
        
  - Update your existing infrastructure.
   
        terraform apply
        
  - Destroy your Infrastructure
  
        terraform destroy
        
  - Destroy a Specific Service insted of all 
        
         terraform destroy --target resource_type.name --target resource_type.name
         
         terraform destroy --target aws_instance.httpd
        
  - Terraform Console
  
        terraform console
        
  - Sample configuration to craete a EC2_Server
  
        provider "aws" {
        profile = "terraform_user"
              region = "eu-west-1"
        }
        resource "aws_instance" "my-ec2-ins" {
          ami     = "ami-02df9ea15c1778c9c"
          instance_type = "t2.micro"

          tags = {
            Name = "terraform_anand"
          }
        }
        
### Note

        [root@ip-172-31-31-8 ec2_demo]# cat ~/.aws/config 
        [default]
        region = eu-west-1
        [profile terraform_user]
        region = eu-west-1
        [root@ip-172-31-31-8 ec2_demo]# cat ~/.aws/credentials 
        [default]
        aws_access_key_id = AKIAJHO7C627BHFOAMOA
        aws_secret_access_key = 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
        [terraform_user]
        aws_access_key_id = AKIAXSB5ISV5RWIQFB26
        aws_secret_access_key = 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

## Variable Types

### Simple Variable types

    - String 
    - Number
    - Boolean
    
### Complex types

    - List
    - Set
    - Map 
    - Object
    - Tuple
    

## Variable Declaration

  - String declaration
  
        variable "myvar" {
          type = "string"
          default = "Hello Platform"
      }
      
      Run : 
      
        - terraform console
        - var.myvar.  or "${var.myvar}"
        
  - Map Declaration
  
        variable "mymap" {
          type = map(string)
          default = {
        mykey = "my value"
          }
        }
      Run :
      
        - var.mymap
        - var.mymap["mykey"] or "${var.mymap["mykey"]}"
        
  - List Declaration
  
        variable "mylist" {
          type = list
          default = [1,2,3]
        }
        
       Run:
       
         - var.mylist
         - var.mylist[1]
         - element(var.mylist, 1)
         - slice(var.mylist, 0, 2)
  
     
## Starting from scrach

### EC2 Instace Creation with direct process

        provider "aws" {
            region = "eu-west-1"
        }

        resource "aws_instance" "httpd" {
            count   =  2
            ami              = "ami-0ff760d16d9497662"
            instance_type    = "t2.micro"
            key_name         = "Anand-Mac-Ireland"
            monitoring       = true
            vpc_security_group_ids = ["sg-0635bbd6766f3cab1"]
            subnet_id        =  "subnet-e7257faf"
            tags = {
                Name = "apache-test"
                Env  = "test"
            }
        }
        
### EC2 creation with Variables and See the Output with Output Variable

                provider "aws" {
                    region = "${var.region_name}"
                }

                variable "instance_count" {
                    default = "1"
                }

                variable "ami_types" {
                    type = map(string)
                    default = {
                        "eu-west-1" = "ami-0ff760d16d9497662"
                        "eu-east-2" = "ami-0ff760d16d9497663"
                        "eu-west-3" = "ami-0ff760d16d9497662"
                    }
                }

                variable "region_name" {
                    default = "eu-west-1"
                }

                variable "instance_type" {
                    default = "t2.micro"
                }

                variable "monitoring" {
                    default = "true"
                }

                variable "tags" {
                    type = map(string)
                    default = {
                        "name" = "apache-test"
                        "env" = "test"
                    }
                }

                resource "aws_instance" "httpd" {
                    count            = "${var.instance_count}"
                    ami              = "${lookup(var.ami_types,var.region_name)}"
                    instance_type    = "${var.instance_type}"
                    key_name         = "Anand-Mac-Ireland"
                    monitoring       = "${var.monitoring}"
                    vpc_security_group_ids = ["sg-0635bbd6766f3cab1"]
                    subnet_id        = "subnet-e7257faf"
                    tags = "${var.tags}"
                }

                output "instance_ip" {
                    value = "${aws_instance.httpd.*.public_ip}"
                }


                // TAGS DECLARATION WITH LIST
                // variable "instance_tags" {
                //  type = "list"
                //  default = ["Terraform-1", "Terraform-2"]
                // }

                // tags = {
                //    Name  = "${element(var.instance_tags, count.index)}"
                //    Batch = "5AM"
                //  }

        Note : 
        
            ## See the Output
            
            terraform output
            
### USER_DATA

    The user_data only runs at instance launch time.
    
    Way -1 : 
    
          resource "aws_instance" "httpd" {
          count            = "${var.instance_count}"
          ami              = "${lookup(var.ami_types,var.region_name)}"
          instance_type    = "${var.instance_type}"
          key_name         = "Anand-Mac-Ireland"
          monitoring       = "${var.monitoring}"
          vpc_security_group_ids = ["sg-0635bbd6766f3cab1"]
          subnet_id        = "subnet-e7257faf"
          user_data = <<-EOT
              #! /bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl enable httpd
              echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
              sudo service httpd start
          EOT
          tags = "${var.tags}"

          }
   
    Way -2 :
    But we prefer to use a file() function:
    
          // user_data        = "${file("software_install.sh")}"
          
              provider "aws" {
                  region = "${var.region_name}"
              }

              variable "instance_count" {
                  default = "1"
              }

              variable "ami_types" {
                  type = map(string)
                  default = {
                      "eu-west-1" = "ami-0ff760d16d9497662"
                      "eu-east-2" = "ami-0ff760d16d9497663"
                      "eu-west-3" = "ami-0ff760d16d9497662"
                  }
              }

              variable "region_name" {
                  default = "eu-west-1"
              }

              variable "instance_type" {
                  default = "t2.micro"
              }

              variable "monitoring" {
                  default = "true"
              }

              variable "tags" {
                  type = map(string)
                  default = {
                      "name" = "apache-test"
                      "env" = "test"
                  }
              }

              resource "aws_instance" "httpd" {
                  count            = "${var.instance_count}"
                  ami              = "${lookup(var.ami_types,var.region_name)}"
                  instance_type    = "${var.instance_type}"
                  key_name         = "Anand-Mac-Ireland"
                  monitoring       = "${var.monitoring}"
                  vpc_security_group_ids = ["sg-0635bbd6766f3cab1"]
                  subnet_id        = "subnet-e7257faf"
                  user_data        = "${file("software_install.sh")}"
                  tags = "${var.tags}"

              }

              output "instance_ip" {
                  value = "${aws_instance.httpd.*.public_ip}"
              }

          
          
          software_install.sh : 
          
            #!/bin/bash
                  sudo yum update -y
                  sudo yum install -y httpd
                  sudo systemctl enable httpd
                  echo "<h1>Hi Anand !!! You are rocking with Terraform Now </h1>" | sudo tee /var/www/html/index.html
                  sudo service httpd start
          
            
# Provisinor file

      Copies the myapp.conf file to /etc/myapp.conf
      
      provisioner "file" {
        source      = "conf/myapp.conf"
        destination = "/etc/myapp.conf"
      }

    resource "aws_key_pair" "mykey" {
      key_name   = "mykey"
      public_key = file(var.PATH_TO_PUBLIC_KEY)
    }

    resource "aws_instance" "example" {
      ami           = var.AMIS[var.AWS_REGION]
      instance_type = "t2.micro"
      key_name      = aws_key_pair.mykey.key_name

      provisioner "file" {
        source      = "script.sh"
        destination = "/tmp/script.sh"
      }
      provisioner "remote-exec" {
        inline = [
          "chmod +x /tmp/script.sh",
          "sudo /tmp/script.sh",
        ]
      }
      connection {
        host        = coalesce(self.public_ip, self.private_ip)
        type        = "ssh"
        user        = var.INSTANCE_USERNAME
        private_key = file(var.PATH_TO_PRIVATE_KEY)
      }
    }


## Sequrity Group

    resource "aws_security_group" "from_europe" {
      name = "from_europe"

      ingress {
        from_port   = "443"
        to_port     = "443"
        protocol    = "tcp"
        cidr_blocks = data.aws_ip_ranges.european_ec2.cidr_blocks
      }
