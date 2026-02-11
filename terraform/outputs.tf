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
  description = "Frontend URL"
  value       = "http://${aws_eip.app.public_ip}:5173"
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
  description = "SSH into Jenkins"
  value       = "ssh -i your-key.pem ec2-user@${aws_eip.jenkins.public_ip}"
}

output "ssh_app" {
  description = "SSH into App server"
  value       = "ssh -i your-key.pem ec2-user@${aws_eip.app.public_ip}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}