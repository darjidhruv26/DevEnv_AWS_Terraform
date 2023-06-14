# DevEnv_AWS_Terraform

![tf_aws ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/ce02599c-20bb-44cd-8964-e34c81e33018)

- HashiCorp Terraform is an infrastructure as code tool that lets you define both cloud and on-prem resources in human-readable configuration files that you can version, reuse, and share. You can then use a consistent workflow to provision and manage all of your infrastructure throughout its lifecycle. Terraform can manage low-level components like compute, storage, and networking resources, as well as high-level components like DNS entries and SaaS features.

# Stape: 1

- Create a file 
```providers.tf```
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
And run this command `terraform init`

[Reference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

# Stape: 2 Create a VPC environment

## Stape: 2.1 Deploy the VPC

- Create a file `main.tf `
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
![vpc ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/4d1670c2-8f19-440e-ab92-bb62f17826f5)
[Terraform Docs Reference for creating a VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)

## Stape: 2.2 Deploy Subnet

- Add subnet configuretions in `main.tf`
```bash
resource "aws_subnet" "dhruv_public_subnet" {
  vpc_id                  = aws_vpc.dhruv_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "dev-public"
  }
}
```
![subnet ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/c308f5ae-8214-4e3b-b035-ef8cdd21a0cf)
[Terraform Docs Reference for creating a Subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)

## Stape: 2.3 Create Internet Gateway

- Add Internet Gateway configuretions in `main.tf`
```bash
resource "aws_internet_gateway" "dhruv_internet_gateway" {
  vpc_id = aws_vpc.dhruv_vpc.id

  tags = {
    Name = "dev-igw"
  }
}
```
![IG ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/1cbd05c5-7349-4c10-8260-798efbdc34c5)

[Terraform Docs Reference for creating a Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)

## Stape: 2.4 Create Route Table

- Add Route Table configuretions in `main.tf`
```bash
resource "aws_route_table" "dhruv_public_rt" {
  vpc_id = aws_vpc.dhruv_vpc.id

  tags = {
    Name = "dev_public_rt"
  }
}
```
### Defining Route
- Add Route in `main.tf`
```bash
resource "aws_route" "def_route" {
  route_table_id         = aws_route_table.dhruv_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dhruv_internet_gateway.id
}
```
### Associate subnet with Route Table
- Associate subnet with route table in `main.tf`
```bash
resource "aws_route_table_association" "dhruv_public_assoc" {
  subnet_id      = aws_subnet.dhruv_public_subnet.id
  route_table_id = aws_route_table.dhruv_public_rt.id
}
```

![Rt table ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/111fc7c7-6f27-489c-966e-f0e9f91f9cbb)

[Terraform Docs Reference for creating a Route Table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)
[Terraform Docs Reference for defining a Route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)
[Terraform Docs for Route table association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)

## Stape:2.5 Create Security Group
- Add sucurity group in `main.tf`
```bash
resource "aws_security_group" "dhruv_sg" {
  name        = "dev_sg"
  description = "dev security Group"
  vpc_id      = aws_vpc.dhruv_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
![SG ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/98cb5199-d023-4a31-bf93-d568eeb229ee)

[Terraform Docs for creating a security group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

# Stape: 3 Creating a EC2 Instance

## Selecte AMI Id for creating a EC2 Instance
- In this project we use `Ubuntu Server-20.04`
- AMI ID: `ami-08e5424edfe926b43`
- AMI Name: `ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20230517`
- Owner ID: `099720109477`
```bash
data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20230517"]
  }
}
```
 ## Create Key-Pairs
 
[Terraform Docs for AMI](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ami)

```terraform plan```
- The `terraform plan` command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure. By default, when Terraform creates a plan it:
-- Reads the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.
-- Compares the current configuration to the prior state and noting any differences.
-- Proposes a set of change actions that should, if applied, make the remote objects match the configuration.

```teraform fmt```
- The `terraform fmt` command is used to rewrite Terraform configuration files to a canonical format and style. This command applies a subset of the Terraform language style conventions, along with other minor adjustments for readability.
```terraform state```
- The command will list all resources in the state file matching the given addresses (if any). If no addresses are given, all resources are listed.
![tf state list](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/031fbf1a-a415-4585-a5e1-0cbea66dcd06)

```terraform show```
- The `terraform show` command is used to provide human-readable output from a state or plan file. This can be used to inspect a plan to ensure that the planned operations are expected, or to inspect the current state as Terraform sees it.Machine-readable output is generated by adding the -json command-line flag.

```terraform apply```
- When you run `terraform apply` without passing a saved plan file, Terraform automatically creates a new execution plan as if you had run terraform plan, prompts you to approve that plan, and takes the indicated actions. You can use all of the planning modes and planning options to customize how Terraform will create the plan.You can pass the `-auto-approve` option to instruct Terraform to apply the plan without asking for confirmation.

```terraform destroy``
- The `terraform destroy` command is a convenient way to destroy all remote objects managed by a particular Terraform configuration.

