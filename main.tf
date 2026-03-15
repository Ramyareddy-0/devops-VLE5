provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Dev-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.dev_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-2a"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rt_assoc" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.dev_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2" {
  count = 2
  ami = "ami-03f0544597f43a91d"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_subnet.id
  key_name = "EC2"
  security_groups = [aws_security_group.sg.id]
}