provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "existing" {
  id = "vpc-0c144991f30bbb9ab" 
}

data "aws_subnet" "public" {
  id = "subnet-08149cb0fe0b5dfb8"
}

data "aws_route_table" "public" {
  id = "rtb-0fd149856f8a84298"  
}

resource "aws_route_table_association" "public" {
  subnet_id      = data.aws_subnet.public.id
  route_table_id = data.aws_route_table.public.id
}

resource "aws_security_group" "web" {
  vpc_id = data.aws_vpc.existing.id

  ingress {
    from_port   = 22
    to_port     = 22 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 443
    to_port     = 443  
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 8000     
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0 
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  key_name      = "pavan.pem"  # Update this line with your key pair name
  subnet_id     = data.aws_subnet.public.id 
  vpc_security_group_ids = [aws_security_group.web.id]
  associate_public_ip_address = true

  tags = {
    Name = "Web Server"
  }
}

