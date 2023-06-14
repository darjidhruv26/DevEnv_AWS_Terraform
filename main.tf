resource "aws_vpc" "dhruv_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "dev"
  }
}

resource "aws_subnet" "dhruv_public_subnet" {
  vpc_id                  = aws_vpc.dhruv_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "dhruv_internet_gateway" {
  vpc_id = aws_vpc.dhruv_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "dhruv_public_rt" {
  vpc_id = aws_vpc.dhruv_vpc.id

  tags = {
    Name = "dev_public_rt"
  }

}

resource "aws_route" "def_route" {
  route_table_id         = aws_route_table.dhruv_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dhruv_internet_gateway.id
}

resource "aws_route_table_association" "dhruv_public_assoc" {
  subnet_id      = aws_subnet.dhruv_public_subnet.id
  route_table_id = aws_route_table.dhruv_public_rt.id
}

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

resource "aws_key_pair" "dhruv_auth" {
  key_name   = "dhruvkey"
  public_key = file("~/.ssh/dhruvkey.pub")
}

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

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/dhruvkey"
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-command"] : ["bash", "-c"]
  }
}