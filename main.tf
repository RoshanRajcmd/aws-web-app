ssh -i TMAWSKeyPair.pe, ec2_user@10.0.1.68

Amplify - used to build, deploy and host websites
API Gateway - used to build HTTP, REST and WebSocket APIs
# main.tf file
## Provider Block
provider "aws" {
    profile = "default"
    region = "us-west-1"
}

## create VPC
resource "aws_vpc" "my_test_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

## create Subnet
resource "aws_subnet" "my_test_subnet" {
  vpc_id = aws_vpc.my_test_vpc.id
  cidr_block = var.subnet_cidr
  tags = {
    Name = var.subnet_name
  }
}

## create Internet Gateway route
resource "aws_internet_gateway" "my_ig" {
  vpc_id = aws_vpc.my_test_vpc.id
  tags = {
    Name = var.igw_name
  }
}

## create Route Table with IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_test_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_ig.id
  }

  tags = {
    Name = var.igw_name
  }
}

## Associate route table with subnet
resource "aws_route_table_association" "public_1_rt_assoc" {
  subnet_id = aws_subnet.my_test_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

## Creates new security group open to HTTP traffic
resource "aws_security_group" "app_sg" {
    name = "HTTP"
    vpc_id = aws_vpc.my_test_vpc.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol - -1
        cidr_block = ["0.0.0.0/0"]
    }
}

##Creates EC2 instance
resource "aws_instance" "app_istance" {
    ami = var.ec2_ami
    instance_type = "t2.micro"

    subnet_id = aws_subnet.my_test_subnet.id
    vpc_security_group_ids = [aws__security_group.app_sg.id]
    associate_public_ip_address = true

    user_data = <<-EDF
    #!/bin/bash -ex

    amazon-linux-extras install nginx1 -y
    echo "<h1>This is my new server</h1>" > /usr/share/nginx/html/index.html
    systemctl enable nginx
    EDF
    
    tags = {
        "Name" : var.ec2_name
    }
}

output "instance_id"{
    description = "ID of the EC2 instance"
    value = aws_instance.app_server.id
}

output "instance_public_ip"{
    description = "Public IO address of the EC2 instance"
    value = aws_instance.app_server.public_ip
}

# variables.tf
variable "vpc_cidr"{
    description = "Value of the CIDR rage fro the VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "vpc_name"{
    description = "Value of the name for the VPC"
    type = string
    default = "MyTestVPC"
}

variable "subnet_cidr"{
    description = "Value of the subnet cidr for the VPC"
    type = string
    default = "10.0.1.0/24"
}

variable "subnet_name"{
    description = "Value of the subnet name for the VPC"
    type = string
    default = "MyTestSubnet"
}

variable "igw_name"{
    description = "Value of the Internet Gateway for the VPC"
    type = string
    default = "MyTestIGW"
}

variable "ec2_ami"{
    description = "Value of the AMI Id for the VPC"
    type = string
    default = "ami-007868000=5aea67c54"
}

variable "ec2_name"{
    description = "Value of the AMI name for the VPC"
    type = string
    default = "MyTestEC2"
}

# terraform.tfvars
vpc_cidr = "10.0.0.0/16"
vpc_name = "MyTestVPC"

subnet_cidr = "10.0.1.0/24"
subnet_name = "MyTestSubnet"

igw_name = "MyTestIGw"

ec2_ami = "ami-007868000=5aea67c54"
ec2_name = "MyTestEC2"