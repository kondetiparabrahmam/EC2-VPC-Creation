terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "us-west-2"
  access_key = "AKIA44Y6CSRWG4WKJ2AG" # Replace with your actual access key
  secret_key = "A+DWtxtMA84pWtPrJqEd7LIaHNw9QIPOs/Ow/Cby" # Replace with your actual secret key
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

# Create Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "MySubnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

# Create Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "MyRouteTable"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create EC2 Instance
resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3" # You can replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id

  tags = {
    Name = "ExampleAppServerInstance"
  }

  # Attach EBS Volume to the Instance
  root_block_device {
    volume_size = 8 # Size in GiB (default storage)
    volume_type = "gp2" # General Purpose SSD
    delete_on_termination = true
  }
}

# Output Subnet ID
output "subnet_id" {
  value       = aws_subnet.my_subnet.id
  description = "The ID of the created subnet"
}

# Output EC2 Instance ID
output "instance_id" {
  value       = aws_instance.app_server.id
  description = "The ID of the created EC2 instance"
}

# Output EBS Volume ID
output "ebs_volume_id" {
  value       = aws_instance.app_server.root_block_device[0].volume_id
  description = "The ID of the attached EBS volume"
}
