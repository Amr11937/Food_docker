variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  default     = "food-delivery"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  default     = "dev"
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
}

variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
}

variable "docker_image_tag" {
  description = "Docker image tag to deploy"
  default     = "latest"
}

variable "mongodb_username" {
  description = "MongoDB username"
  type        = string
  sensitive   = true
}

variable "mongodb_password" {
  description = "MongoDB password"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "app_instance_type" {
  description = "EC2 instance type for application server"
  default     = "t3.medium"
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins server"
  default     = "t3.medium"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  default     = "0.0.0.0/0"  # Restrict this to your IP in production
}
