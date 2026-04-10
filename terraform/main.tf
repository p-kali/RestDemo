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

#Role
resource "aws_iam_role" "ec2_role" {
  name = "devops-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

#Policy ECR read
resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#Policy SSM read
resource "aws_iam_role_policy_attachment" "ssm_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

#Create profile/role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "devops-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "devops_demo_ec2" {
  #ami = "ami-0ec10929233384c7f"
  #instance_type = "t3.micro"
  #key_name = "qa-key"
  count = 2
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
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

              # Install AWS CLI  <-- ADD HERE
              apt-get install -y unzip curl
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install

              # Install Java
              apt-get install -y openjdk-17-jre-headless

              # Verify installations
              docker --version
              java -version

              EOF
}

# # Create Elastic IP
# resource "aws_eip" "devops_eip" {
#   tags = {
#     Name = "devops-demo-eip"
#   }
# }

# # Associate EIP with EC2
# resource "aws_eip_association" "devops_eip_assoc" {
#   instance_id   = aws_instance.devops_demo_ec2.id
#   allocation_id = aws_eip.devops_eip.id
# }

#  It won't work, because current RDS is in different VPC
# resource "aws_security_group_rule" "allow_ec2_to_rds" {
#   type                     = "ingress"
#   from_port                = 5432
#   to_port                  = 5432
#   protocol                 = "tcp"
#   security_group_id        = var.rds_security_group_id
#   source_security_group_id = aws_security_group.app_sg.id
# }

output "app_ips" {
  #value = aws_instance.devops_demo_ec2.public_ip #Single EC2 instance
  value = aws_instance.devops_demo_ec2[*].public_ip
}

# output "elastic_ip" {
#   value = aws_eip.devops_eip.public_ip
# }