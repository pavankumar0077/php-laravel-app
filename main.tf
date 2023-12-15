provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example_instance" {
  ami           = "ami-0fc5d935ebf8bc3bc"  # Specify the AMI ID for your desired image
  instance_type = "t2.micro"
  
  key_name = "pavan"  # Specify the name of your key pair

  tags = {
    Name    = "example-instance"
    Region  = "us-east-1"
  }

  // Define security group to allow inbound traffic on ports 22, 80, and 443
  vpc_security_group_ids = ["${aws_security_group.example_sg.id}"]
}

# Create a security group allowing inbound traffic on ports 22, 80, and 443
resource "aws_security_group" "example_sg1" {
  name        = "example-sg1"
  description = "Allow inbound traffic on ports 22, 80, and 443"

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

  # Allow outbound traffic on port 443 (HTTPS)
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output the public IP address of the created instance
output "public_ip" {
  value = aws_instance.example_instance.public_ip
}

