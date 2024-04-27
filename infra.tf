# provider plugin details
#terraform {
 # required_providers {
  #  aws = {
   #   source  = "hashicorp/aws"
    #  version = "~> 3.0"
    }
  }
}
# provider  details
provider "aws" {
  region = "us-east-1"
}
# resource details
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/20" # Change this CIDR block as needed
  enable_dns_support = true
  enable_dns_hostnames = true
}
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id 
  cidr_block = "10.0.1.0/24" # Change this CIDR block as needed
  map_public_ip_on_launch = true

}
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}
resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "Allow inbound traffic on ports 80 and 22"

  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "my_instance" {
  ami           = "ami-080e1f13689e07408" # Change this to your desired AMI
  instance_type = "t2.micro" # Change this to your desired instance type
  subnet_id     = aws_subnet.my_subnet.id
 associate_public_ip_address = true
#security_groups = [aws_security_group.my_security_group.name]
    user_data = <<-EOF
#!/bin/bash
sudo apt-get update
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install fontconfig openjdk-17-jre -y
sudo apt-get install jenkins -y
sudo apt-get install -y maven
EOF

  tags = {
    Name = "my_instance"
  }
}
# Resource2
resource "aws_instance" "my_instance2" {
  ami           = "ami-080e1f13689e07408" # Change this to your desired AMI
  instance_type = "t2.micro" # Change this to your desired instance type
  subnet_id     = aws_subnet.my_subnet.id
 associate_public_ip_address = true
count=2
tags= {
Name="jenkins-slaves"
}
}
#Resource
resource "aws_instance" "ansible" {
ami="ami-080e1f13689e07408"
instance_type="t2.micro"
subnet_id=aws_subnet.my_subnet.id
associate_public_ip_address=true
 user_data = <<-EOF
#!/bin/bash
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
EOF
tags={
Name="Ansible-server"
}
}
