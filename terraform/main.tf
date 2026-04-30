terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Meilleure gestion des credentials
  skip_credentials_validation = false
  skip_requesting_account_id  = false
}

# Data source pour récupérer les infos du compte
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# Security Group pour permettre SSH et services
resource "aws_security_group" "lab" {
  name        = "${var.instance_name}-sg"
  description = "Security group for DevOps Network Lab"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permettre tout le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.instance_name}-sg"
    Environment = var.environment
  }
}

# Instance EC2
resource "aws_instance" "lab" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.lab.id]
  associate_public_ip_address = var.enable_public_ip

  # Root volume configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = false
  }

  # Tags
  tags = {
    Name        = var.instance_name
    Environment = var.environment
    CreatedBy   = "Terraform"
    Project     = "DevOps-Network-Lab"
  }

  # Metadata options for IMDSv2 (security best practice)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Wait for instance to be running
resource "aws_instance_state" "lab" {
  instance_id = aws_instance.lab.id
  state       = "running"

  timeouts {
    create = "5m"
  }
}
