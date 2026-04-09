terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
provider "aws" {
  #region = "us-east-1"
  region = var.aws_region
}

#Security Group
resource "aws_security_group" "app_sg" {
  name = "devops-demo-app-sg"
  description = "Allow SSH and App traffic"
  vpc_id = aws_vpc.devops_vpc.id

  ingress {
    description = "App port"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Http port"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port"
    from_port = 8080
    to_port = 8081
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-sg"
  }
}

resource "aws_instance" "devops_demo_ec2" {
  #ami = "ami-0ec10929233384c7f"
  #instance_type = "t3.micro"
  #key_name = "qa-key"
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  subnet_id = aws_subnet.public_subnet_1.id
  tags = {
    Name = "devops-demo-ec2"
  }
  user_data_replace_on_change = true
  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1
              set -ex

              export DEBIAN_FRONTEND=noninteractive

              apt-get update -y
              apt-get upgrade -y

              # Install Docker
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu

              # Install Java
              apt-get install -y openjdk-17-jre-headless

              # Verify installations
              docker --version
              java -version

              EOF
}

# Create Elastic IP
resource "aws_eip" "devops_eip" {
  tags = {
    Name = "devops-demo-eip"
  }
}

# Associate EIP with EC2
resource "aws_eip_association" "devops_eip_assoc" {
  instance_id   = aws_instance.devops_demo_ec2.id
  allocation_id = aws_eip.devops_eip.id
}

output "app_ip" {
  value = aws_instance.devops_demo_ec2.public_ip
}
output "elastic_ip" {
  value = aws_eip.devops_eip.public_ip
}