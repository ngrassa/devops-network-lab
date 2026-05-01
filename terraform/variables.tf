# Variables pour le projet DevOps Network Lab

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.large"
}

variable "instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
  default     = "devops-network-lab"
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS AMI ID for us-east-1"
  type        = string
  default     = "ami-0e86e20dae9224db8"
}

variable "key_name" {
  description = "AWS EC2 Key Pair name (must exist in your AWS account)"
  type        = string
  default     = "vockey"
}

variable "enable_public_ip" {
  description = "Enable public IP assignment"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}
