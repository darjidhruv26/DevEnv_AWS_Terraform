# Project :)

# Create a Development Environment on AWS using Terraform :)

![tf_aws ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/ce02599c-20bb-44cd-8964-e34c81e33018)

- `HashiCorp Terraform` is an `infrastructure as a code` tool that lets you define both cloud and on-prem resources in human-readable configuration files that you can version, reuse, and share. You can then use a consistent workflow to provision and manage all of your infrastructure throughout its lifecycle. Terraform can manage low-level components like computing, storage, and networking resources, as well as high-level components like DNS entries and SaaS features.

# About this project

- Creating a development environment on AWS using Terraform is a powerful approach that allows developers to provision and manage infrastructure as code. By leveraging the capabilities of Terraform and AWS, developers can easily spin up and configure resources required for their development work, ensuring consistency and reproducibility across environments. Let's explore the steps involved in setting up a development environment on AWS using Terraform.
1. Prerequisites:
   - An AWS account with appropriate permissions.
   - Terraform installed on your local machine.

2. Configure AWS Credentials:
   - Obtain your AWS `access key` ID and `secret access key` from the AWS Management Console.
   - Set up your AWS credentials either by exporting environment variables or using `AWS CLI`'s `aws configure` command.

3. Initialize Terraform:
   - Create a new directory for your Terraform project.
   - Open a terminal in the project directory and run `terraform init`.
   - This command initializes the Terraform project and downloads the necessary provider plugins.

4. Write Terraform Configuration:
   - Create a new file, typically named `main.tf`, and define your desired AWS resources.
   - For a development environment, you might provision resources like virtual machines (EC2 instances), virtual networks (VPC) or other necessary services.
   - Specify resource details such as instance types, network configurations, security groups, and any other required parameters.

5. Create the Development Environment:
   - Run `terraform plan` to see a preview of the changes Terraform will make.
   - Review the plan to ensure it aligns with your expectations.
   - Execute `terraform apply` to create the development environment on AWS.
   - Terraform will prompt for confirmation before making any changes.
   - Type `yes` to proceed, and Terraform will provision the specified resources.

6. Access and Configure the Environment:
   - Once the provisioning process completes, Terraform will display the `output variables` defined in your configuration file.
   - These outputs might include the IP addresses, access keys, or other important details required to connect to your development environment.
   - Make note of these outputs and use them to access and configure your development environment accordingly.

7. Managing the Environment:
   - To make changes to your development environment, modify your Terraform configuration file (e.g., `main.tf`) as needed.
   - Run `terraform plan` to preview the changes and `terraform apply` to apply them.
   - Terraform will automatically determine the delta between the desired and existing state and apply the necessary updates.
   
8. Destroying the Environment:
   - When you no longer need the development environment, you can use Terraform to clean up the provisioned resources.
   - Run `terraform destroy` to destroy all the resources created by Terraform.
   - Confirm the destruction by typing `yes` when prompted.

- By following these steps, you can easily `create and manage a development environment on AWS using Terraform`. This approach enables `infrastructure-as-code` practices, ensures consistency across environments, and allows for easy reproducibility and scalability of your development setup.

# Simple Project Architecture

![Slide1](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/54bc89cb-a66d-4d0f-ae42-587ceac2e8f9)

# Step 1: AWS Provider

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

- Terraform Docs for [AWS Provide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

# Step 2: Create a VPC environment

## Step 2.1: Deploy the VPC

- Create a file `main.tf `
 
```
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

- Add subnet configuration in `main.tf`

```
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

## Step 2.3: Create an Internet Gateway

- Add Internet Gateway configurations in `main.tf`

```
resource "aws_internet_gateway" "dhruv_internet_gateway" {
  vpc_id = aws_vpc.dhruv_vpc.id

  tags = {
    Name = "dev-igw"
  }
}
```

![IG ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/1cbd05c5-7349-4c10-8260-798efbdc34c5)

- Terraform Docs Reference for creating an [Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway).

## Step 2.4: Create Route Table

- Add Route Table configuration in `main.tf`.

```
resource "aws_route_table" "dhruv_public_rt" {
  vpc_id = aws_vpc.dhruv_vpc.id

  tags = {
    Name = "dev_public_rt"
  }
}
```

- Terraform Docs Reference for creating a [Route Table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table).

### Step 2.4.1: Defining Route

- Add Route in `main.tf`

```
resource "aws_route" "def_route" {
  route_table_id         = aws_route_table.dhruv_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dhruv_internet_gateway.id
}
```
- Terraform Docs Reference for defining a [Route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route).

### Step 2.4.2: Associate subnet with Route Table

- Associate subnet with route table in `main.tf`

```
resource "aws_route_table_association" "dhruv_public_assoc" {
  subnet_id      = aws_subnet.dhruv_public_subnet.id
  route_table_id = aws_route_table.dhruv_public_rt.id
}
```

![Rt table ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/111fc7c7-6f27-489c-966e-f0e9f91f9cbb)

- Terraform Docs for [Route table association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association).

## Step 2.5: Create a Security Group

- Add a security group in `main.tf`

```
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

# Step 3: Creating an EC2 Instance

## Step 3.1: Select AMI Id for creating an EC2 Instance

- In this project, we use `Ubuntu Server-20.04`
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
 - It looks like this
 
 ```C:\Users\Dhruv/.ssh/dhruvkey```
 
 - And then press `Enter`
 - key was generated After that run this command in terminal `ls ~/.ssh`
 - You can see all directories and files in `C:\Users\Dhruv\.ssh` 
 - In this, you can see `dhruvkey` and `dhruvkey.pub`
 
 ### Step 3.2.2: Key Apply
 
 - In this part, we use [terraform file function](https://developer.hashicorp.com/terraform/language/functions/file) for passing the public key as a file `path`.
 
 - Add this configuration in `main.tf`.
 
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

- Add this EC2 instance configuration in `main.tf` file.

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

## Step 3.4: Connect the EC2 instance with local system

- For this task run a `ssh -i C:\Users\Dhruv\.ssh\dhruvkey ubuntu@13.233.64.121` in terminal and press `Enter` -> Type `Yes` -> (you are in instance)  

# Step 4: Create SSH Config Scripts

- This SSH configuration script is to allow VS Code to connect our EC2 Instance.
- Create Template file `windows-ssh-config.tpl` for Windows system.

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

- After the provisioner run this command in terminal `cat ~/.ssh/config`.

- The output looks like this.

![ssh config](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/cbb0b9d5-1689-4c0d-99fc-a49c7740873e)

- After that follow this flow

```In Vs code -> View -> Command Palette.. -> Remote-SSH: Connect to Host.. -> select(13.233.64.121) -> Open new VS code Window -> Linux -> Continue -> And see Output like this ```

![VS remote ss](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/05f392f0-b7ef-41cc-8dc2-d4164c89b522)

Terraform Docs [provisioners](https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax)

## Step 4.2: Making a more Optimized and Dynamic script using Terraform variables

- Terraform Variables for choosing dynamic OS
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

- Here `terraform.tfvars` takes precedence over a default `variable.tf` file.

![unix var](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/5e0bdd08-3406-4e93-a9cd-3b826a48a0bd)

- Here `variable inline command` takes precedence over a `terraform.tfvars` file.

- Terraform Docs for [variable](https://developer.hashicorp.com/terraform/language/values/variables).

## Step 4.3: Use Conditional Expressions for choosing an `interpreter`

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

# Step 5: Create Output values

- Create `output.tf` file.

```
output "dev_ip" {
    value = aws_instance.dhruv_node.public_ip
}
```

- Terraform Docs for [output values](https://developer.hashicorp.com/terraform/language/values/outputs).

### Here some Terraform commands use in this project

`terraform fmt`
- The `terraform fmt` command is used to rewrite Terraform configuration files to a canonical format and style. This command applies a subset of the Terraform language style conventions, along with other minor adjustments for readability.

`terraform state`
- The command will list all resources in the state file matching the given addresses (if any). If no addresses are given, all resources are listed.

![tf state list](https://github.com/darjidhruv26/DevEnv_AWS_Terraform/assets/90086813/031fbf1a-a415-4585-a5e1-0cbea66dcd06)

`terraform plan`
- The `terraform plan` command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure. By default, when Terraform creates a plan it:
- Reads the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.
- Compares the current configuration to the prior state and notes any differences.
- Proposes a set of change actions that should, if applied, make the remote objects match the configuration.

`terraform show`
- The `terraform show` command is used to provide human-readable output from a state or plan file. This can be used to inspect a plan to ensure that the planned operations are expected or to inspect the current state as Terraform sees it. Machine-readable output is generated by adding the -json command-line flag.

`terraform apply`
- When you run `terraform apply` without passing a saved plan file, Terraform automatically creates a new execution plan as if you had run `terraform plan`, prompts you to approve that plan, and takes the indicated actions. You can use all of the planning modes and planning options to customize how Terraform will create the plan. You can pass the `-auto-approve` option to instruct Terraform to apply the plan without asking for confirmation.

`terraform destroy`
- The `terraform destroy` command is a convenient way to destroy all remote objects managed by a particular Terraform configuration.
