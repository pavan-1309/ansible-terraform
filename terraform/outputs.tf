output "environment" {
  description = "Environment name"
  value       = var.environment
}


output "public_ips" {
  description = "Public IP addresses of EC2 instances"
  value       = aws_instance.web[*].public_ip
}

