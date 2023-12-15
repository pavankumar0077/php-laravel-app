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

  // Define security group to allow all incoming traffic
  vpc_security_group_ids = ["${aws_security_group.example_sg.id}"]
}

# Create a security group allowing all incoming traffic
resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Allow all incoming traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output the public IP address of the created instance
output "public_ip" {
  value = aws_instance.example_instance.public_ip
}

