# Project :)

# DevEnv_AWS_Terraform

![tf_aws ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/ce02599c-20bb-44cd-8964-e34c81e33018)

- HashiCorp Terraform is an infrastructure as code tool that lets you define both cloud and on-prem resources in human-readable configuration files that you can version, reuse, and share. You can then use a consistent workflow to provision and manage all of your infrastructure throughout its lifecycle. Terraform can manage low-level components like compute, storage, and networking resources, as well as high-level components like DNS entries and SaaS features.

# Simple Project Architecture

![Slide1](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/94c3c33a-938e-4cd4-ac2b-20917bc6a5ee)

# Step 1:

- Create a file `providers.tf`
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

- Terraform Docs for[AWS_Provide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

# Step 2: Create a VPC environment

## Step 2.1: Deploy the VPC

- Create a file `main.tf `
- 
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
- Terraform Docs Reference for creating a [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)

## Step 2.2: Deploy Subnet

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

- Terraform Docs Reference for creating a [Subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet).

## Step 2.3: Create Internet Gateway

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

- Terraform Docs Reference for creating a [Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway).

## Step 2.4: Create Route Table

- Add Route Table configuretions in `main.tf`.

```bash
resource "aws_route_table" "dhruv_public_rt" {
  vpc_id = aws_vpc.dhruv_vpc.id

  tags = {
    Name = "dev_public_rt"
  }
}
```

### Step 2.4.1: Defining Route
- Add Route in `main.tf`
```bash
resource "aws_route" "def_route" {
  route_table_id         = aws_route_table.dhruv_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dhruv_internet_gateway.id
}
```

### Step 2.4.2: Associate subnet with Route Table
- Associate subnet with route table in `main.tf`
```bash
resource "aws_route_table_association" "dhruv_public_assoc" {
  subnet_id      = aws_subnet.dhruv_public_subnet.id
  route_table_id = aws_route_table.dhruv_public_rt.id
}
```

![Rt table ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/111fc7c7-6f27-489c-966e-f0e9f91f9cbb)

- Terraform Docs Reference for creating a [Route Table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table).
- Terraform Docs Reference for defining a [Route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route).
- Terraform Docs for [Route table association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association).

## Step 2.5: Create Security Group

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

- Terraform Docs for creating a [security group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group).

# Step 3: Creating a EC2 Instance

## Step 3.1: Selecte AMI Id for creating a EC2 Instance

- In this project we use `Ubuntu Server-20.04`
- AMI ID: `ami-08e5424edfe926b43`
- AMI Name: `ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20230517`
- Owner ID: `099720109477`

- Create new file `datasources.tf`

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
- Terraform Docs for [AMI](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ami).

 ## Step 3.2: Create Key-Pairs
 
 ### Step 3.2.1: Generate SSH key
 
 - Go to VS Code terminal and run this command `ssh-keygen -t ed25519` and press Enter
 - You can see this type of output 
 
 ```
 Generating public/private ed25519 key pair.
 C:\Users\Dhruv/.ssh/id_ed25519):
 ```
 
 - Copy this path `C:\Users\Dhruv/.ssh/` and enter your `Key Name`.
 - It look like this
 
 ```C:\Users\Dhruv/.ssh/dhruvkey```
 
 - And then pess `Enter`
 - key was generated After that run this command in terminal `ls ~/.ssh`
 - You can see all directories and files in `C:\Users\Dhruv\.ssh` 
 - In this you can see `dhruvkey` and `dhruvkey.pub`
 
 ### Step 3.2.2: Key Apply
 
 - In this part, we use [terraform file function](https://developer.hashicorp.com/terraform/language/functions/file) for pass public key as file `path`.
 
 - Add this configuretions in `main.tf`.
 
 ```
 resource "aws_key_pair" "dhruv_auth" {
  key_name   = "dhruvkey"
  public_key = file("~/.ssh/dhruvkey.pub")
}
 ```
 
 ![key pairs](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/01e38487-a85b-4d37-b8b1-ea4bcd19a29b)

- Terraform Docs for [aws_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair).
- Terraform Docs for [Terraform file function](https://developer.hashicorp.com/terraform/language/functions/file).

## Step 3.3: Deploy EC2 Instance

- Create Template file `userdata.tpl` for update and install docker

```
#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
sudo apt-get update -y &&
sudo sudo apt-get install docker-ce docker-ce-cli containerd.io -y &&
sudo usermod -aG docker ubuntu 
```

- Add this EC2 instance configuretions in `main.tf` file.

```
resource "aws_instance" "dhruv_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.dhruv_auth.id
  vpc_security_group_ids = [aws_security_group.dhruv_sg.id]
  subnet_id              = aws_subnet.dhruv_public_subnet.id
  user_data              = file("userdata.tpl")
  root_block_device {
    volume_size = 10
  }
  tags = {
    Name = "dhruv-node"
  }
```

 ![ec2 ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/b3d1aeed-c743-46a6-8eba-f92395270586)
 
 - Terraform Docs for [AWS Instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).

## Step 3.4: Connect EC2 instance with local system

- For this task run a `ssh -i C:\Users\Dhruv\.ssh\dhruvkey ubuntu@13.233.64.121` in terminal and press `Enter` -> Type `Yes` -> (you are in instance)  

# Step 4: Create SSH Config Scripts

- This SSH configuration script is to allow VS Code to connect our EC2 Instance.
- Create Template file `windows-ssh-config.tpl` for windows system.

```
add-content -path C:/Users/Dhruv/.ssh/config -value @'

Host ${hostname}
  HostName ${hostname}
  User ${user}
  IdentityFile ${identityfile}
'@  
```

- For Linux or Mac `linux-ssh-config.tpl`

```
cat << EOF >> ~/.ssh/config

Host ${hostname}
  HostName ${hostname}
  User ${user}
  IdentityFile ${identityfile}
EOF  
```

## Step 4.1: Add provisioner

- Add provisioner in `main.tf` file.

```
  provisioner "local-exec" {
    command = templatefile("windows-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/dhruvkey"
    })
    interpreter = ["Powershell", "-command"] 
    }
}
```

- After provisioner run this command in terminal `cat ~/.ssh/config`.

- Output is look like this.

![ssh config](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/cbb0b9d5-1689-4c0d-99fc-a49c7740873e)

- After that follow this flow

```In Vs code -> View -> Command Palette.. -> Remote-SSH: Connect to Host.. -> select(13.233.64.121) -> Open new VS code Window -> Linux -> Continue -> And see Output like this ```

![VS remote ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/05f392f0-b7ef-41cc-8dc2-d4164c89b522)

Terraform Docs [provisioners](https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax)

## Step 4.2: Making more Optimized and Dynamic script using Terraform variables

- Terraform Variables for choose dynamicly OS
- Use `Variable Precedence`
- Create variable file `variables.tf`

```
variable "host_os" {
  type    = string
  default = "windows"
}
```

![var console](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/cc5d874e-29d8-4c31-a5d7-0c79460cadcc)

- Create `terraform.tfvars`

```
host_os = "linux"
```

![linux var](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/305ce99e-ad8b-4851-bfe5-0d5ccadfb1cb)

- Hear `terraform.tfvars` takes a precedence over a default `variable.tf` file.

![unix var](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/5e0bdd08-3406-4e93-a9cd-3b826a48a0bd)

- Hear `variable inline command` takes a precedence over a `terraform.tfvars` file.

- Terraform Docs for [variable](https://developer.hashicorp.com/terraform/language/values/variables).

## Step 4.3: Use Conditional Expressions for choose a `interpreter`

- Add this `provisioner` code in `main.tf` file.
  
```
 provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/dhruvkey"
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-command"] : ["bash", "-c"]
  }
}
```

![conditional ex](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/01ba9902-9961-4e6a-883c-25ce9301fd86)

- Terraform Docs for [conditional expression](https://developer.hashicorp.com/terraform/language/expressions/conditionals).

# Step 5: Cerate Output values

- Create `output.tf` file.

```
output "dev_ip" {
    value = aws_instance.dhruv_node.public_ip
}
```

- Terraform Docs for [output values](https://developer.hashicorp.com/terraform/language/values/outputs).

```teraform fmt```
- The `terraform fmt` command is used to rewrite Terraform configuration files to a canonical format and style. This command applies a subset of the Terraform language style conventions, along with other minor adjustments for readability.

```terraform state```
- The command will list all resources in the state file matching the given addresses (if any). If no addresses are given, all resources are listed.
![tf state list](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/031fbf1a-a415-4585-a5e1-0cbea66dcd06)

```terraform plan```
- The `terraform plan` command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure. By default, when Terraform creates a plan it:
-- Reads the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.
-- Compares the current configuration to the prior state and noting any differences.
-- Proposes a set of change actions that should, if applied, make the remote objects match the configuration.

```terraform show```
- The `terraform show` command is used to provide human-readable output from a state or plan file. This can be used to inspect a plan to ensure that the planned operations are expected, or to inspect the current state as Terraform sees it.Machine-readable output is generated by adding the -json command-line flag.

```terraform apply```
- When you run `terraform apply` without passing a saved plan file, Terraform automatically creates a new execution plan as if you had run terraform plan, prompts you to approve that plan, and takes the indicated actions. You can use all of the planning modes and planning options to customize how Terraform will create the plan.You can pass the `-auto-approve` option to instruct Terraform to apply the plan without asking for confirmation.

```terraform destroy```
- The `terraform destroy` command is a convenient way to destroy all remote objects managed by a particular Terraform configuration.
