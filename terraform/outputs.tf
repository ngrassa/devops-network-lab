# Outputs pour le déploiement

output "instance_id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.lab.id
}

output "instance_arn" {
  description = "ARN de l'instance EC2"
  value       = aws_instance.lab.arn
}

output "public_ip" {
  description = "Adresse IP publique de l'instance EC2"
  value       = aws_instance.lab.public_ip
  sensitive   = false
}

output "private_ip" {
  description = "Adresse IP privée de l'instance EC2"
  value       = aws_instance.lab.private_ip
}

output "public_dns" {
  description = "Nom DNS public de l'instance EC2"
  value       = aws_instance.lab.public_dns
}

output "security_group_id" {
  description = "ID du Security Group"
  value       = aws_security_group.lab.id
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region utilisée"
  value       = var.aws_region
}

output "connection_string" {
  description = "Commande SSH pour se connecter à l'instance"
  value       = "ssh -i your-key.pem ubuntu@${aws_instance.lab.public_ip}"
}

output "deployment_info" {
  description = "Informations complètes de déploiement"
  value = {
    instance_id       = aws_instance.lab.id
    public_ip         = aws_instance.lab.public_ip
    private_ip        = aws_instance.lab.private_ip
    instance_type     = aws_instance.lab.instance_type
    availability_zone = aws_instance.lab.availability_zone
    ami               = aws_instance.lab.ami
  }
}
