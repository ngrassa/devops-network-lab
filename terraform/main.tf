provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "lab" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  key_name      = "vockey"
  tags = {
    Name = "devops-network-lab"
  }
}

output "public_ip" {
  value = aws_instance.lab.public_ip
}
