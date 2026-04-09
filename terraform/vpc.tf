#Create VPC
resource "aws_vpc" "devops_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "devops-vpc"
  }
}

#Create Public Subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-public-subnet"
  }
}

#Create Public Subnet
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-public-subnet"
  }
}

#Create Private subnet
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"
}

#Create Private subnet
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-1b"
}

#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name = "devops-igw"
  }
}

#Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "devops-public-rt"
  }
}

#Associate Route Table with Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

