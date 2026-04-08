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

  # App will be run in containers
  # Since containers are internal, no need to open the port to public
  # ingress {
  #   description = "App port"
  #   from_port = 8080
  #   to_port = 8081
  #   protocol = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

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
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
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

              # Install Nginx
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx

              # Configure Nginx reverse proxy
              cat <<EOF2 > /etc/nginx/sites-available/devops-app
              server {
                  listen 80;

                  location / {
                      proxy_pass http://localhost:8080;
                      proxy_set_header Host \$host;
                      proxy_set_header X-Real-IP \$remote_addr;
                  }
              }
              EOF2

              ln -s /etc/nginx/sites-available/devops-app /etc/nginx/sites-enabled/
              rm -f /etc/nginx/sites-enabled/default
              systemctl restart nginx

              # Verify installations
              docker --version
              nginx -v
              java -version

              mkdir -p /home/ubuntu/app

              cd /home/ubuntu

              echo "blue" > active_env
              echo "initial" > active_sha
              echo "initial" > previous_sha
              touch deploy-history.log

              #chown -R ubuntu:ubuntu /home/ubuntu
              chown ubuntu:ubuntu /home/ubuntu/active_env
              chown ubuntu:ubuntu /home/ubuntu/active_sha
              chown ubuntu:ubuntu /home/ubuntu/previous_sha
              chown ubuntu:ubuntu /home/ubuntu/deploy-history.log

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