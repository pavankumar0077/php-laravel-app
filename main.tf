provider "aws" {
  region = "us-east-1"
}

# Existing VPC details
variable "existing_vpc_id" {
  description = "ID of the existing VPC"
  default     = "vpc-0c144991f30bbb9ab"
}

# Existing key pair name
variable "key_pair_name" {
  description = "Name of the existing key pair"
  default     = "your-key-pair-name"  # Replace with your actual key pair name
}

# Create a new security group
resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Allow inbound traffic on ports 22, 80, 443, and 8000"

  ingress {
    from_port   = 22  # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80  # HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443  # HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000  # Custom application port
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.existing_vpc_id
}

# Create a public subnet in the existing VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = var.existing_vpc_id
  cidr_block              = "10.0.1.0/24"  # Choose an appropriate CIDR block for your public subnet
  availability_zone       = "us-east-1a"    # Choose your desired availability zone

  map_public_ip_on_launch = true  # This will automatically assign public IPs to instances in this subnet

  tags = {
    Name = "public-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "example_igw" {
  vpc_id = var.existing_vpc_id

  tags = {
    Name = "example-igw"
  }
}

# Associate the public subnet with the main route table of the existing VPC
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_vpc.main_route_table_association[0].id
}

resource "aws_instance" "example_instance" {
  ami           = "ami-0fc5d935ebf8bc3bc"  # Specify the AMI ID for your desired image
  instance_type = "t2.micro"
  
  key_name      = var.key_pair_name  # Specify the name of your key pair
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name    = "example-instance"
    Region  = "us-east-1"
  }

  vpc_security_group_ids = [aws_security_group.example_sg.id]
}

# Output the public IP address of the created instance
output "public_ip" {
  value = aws_instance.example_instance.public_ip
}

