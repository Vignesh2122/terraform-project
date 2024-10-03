provider "aws" {
  region = "ap-south-1"
}



resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/20"

  tags = {
    Name = "MainVPC"
  }
}


resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MainIGW"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}


resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.publicsubnet.id  
  route_table_id = aws_route_table.public_rt.id  
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "WebSecurityGroup"
  }
}


data "aws_ami" "latest" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}


resource "aws_instance" "Dev" {
  ami                    = data.aws_ami.latest.id 
  instance_type         = "t2.medium" 
  
  subnet_id             = aws_subnet.publicsubnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]  
  
  associate_public_ip_address = true 

  tags = {
    Name = "DevInstance"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
  EOF
}
 

