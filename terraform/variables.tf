variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
}

variable "ami_id" {
  description = "Ubuntu AMI"
}

variable "rds_security_group_id" {
  description = "RDS Security group ID"
}