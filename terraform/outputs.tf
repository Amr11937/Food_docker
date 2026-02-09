output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = aws_eip.jenkins.public_ip
}

output "jenkins_url" {
  description = "Jenkins Web UI URL"
  value       = "http://${aws_eip.jenkins.public_ip}:8080"
}

output "app_public_ip" {
  description = "Public IP of Application server"
  value       = aws_eip.app.public_ip
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = "http://${aws_eip.app.public_ip}"
}

output "admin_url" {
  description = "Admin panel URL"
  value       = "http://${aws_eip.app.public_ip}:5174"
}

output "backend_url" {
  description = "Backend API URL"
  value       = "http://${aws_eip.app.public_ip}:4000"
}

output "ssh_jenkins" {
  description = "SSH command for Jenkins server"
  value       = "ssh -i your-key.pem ec2-user@${aws_eip.jenkins.public_ip}"
}

output "ssh_app" {
  description = "SSH command for Application server"
  value       = "ssh -i your-key.pem ec2-user@${aws_eip.app.public_ip}"
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for uploads"
  value       = aws_s3_bucket.uploads.bucket
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.app.name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "frontend_url" {
  description = "Frontend URL"
  value       = "http://${aws_eip.app.public_ip}:5173"
}
