# DevEnv_AWS_Terraform

![tf_aws ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/ce02599c-20bb-44cd-8964-e34c81e33018)

- HashiCorp Terraform is an infrastructure as code tool that lets you define both cloud and on-prem resources in human-readable configuration files that you can version, reuse, and share. You can then use a consistent workflow to provision and manage all of your infrastructure throughout its lifecycle. Terraform can manage low-level components like compute, storage, and networking resources, as well as high-level components like DNS entries and SaaS features.

# Stape: 1

- Create a file 
```bash
   providers.tf
```
```bash
  terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region                  = "ap-south-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "[replace you aws user]"
}
```
   

And run this command ```bash    terraform init  ```

# Stape: 2 

# Stape: 2.1 Deploy the VPC

- Create a file ```bash   main.tf ```
```bash
  resource "aws_vpc" "dhruv_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "dev"
  }
}
```

-"https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc"
