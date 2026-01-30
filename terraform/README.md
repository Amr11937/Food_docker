# Terraform AWS Deployment for Food Delivery App

This directory contains Terraform configuration files to deploy the Food Delivery application on AWS using ECS Fargate.

## Architecture

- **VPC**: Custom VPC with public and private subnets across 2 availability zones
- **ECS Fargate**: Containerized services (Frontend, Admin, Backend, MongoDB)
- **ALB**: Application Load Balancer for routing traffic
- **EFS**: Persistent storage for MongoDB data
- **S3**: File uploads storage
- **CloudWatch**: Centralized logging

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** installed (v1.0 or higher)
3. **AWS CLI** configured with your credentials
4. **Docker images** pushed to Docker Hub

## Setup Instructions

### 1. Install Terraform

```bash
# Windows (using Chocolatey)
choco install terraform

# Verify installation
terraform --version
```

### 2. Configure AWS CLI

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: us-east-1
# Default output format: json
```

### 3. Update Configuration

Edit `terraform.tfvars` and update:

- `mongodb_password`: Change to a secure password
- `jwt_secret`: Change to a secure random string
- `dockerhub_username`: Your Docker Hub username
- `docker_image_tag`: Tag of your Docker images

### 4. Initialize Terraform

```bash
cd terraform
terraform init
```

### 5. Validate Configuration

```bash
terraform validate
```

### 6. Preview Changes

```bash
terraform plan
```

### 7. Deploy to AWS

```bash
terraform apply
```

Type `yes` when prompted. Deployment takes approximately 10-15 minutes.

### 8. Get Application URLs

```bash
terraform output
```

## File Structure

- `main.tf`: Main configuration and S3 bucket
- `variables.tf`: Variable definitions
- `terraform.tfvars`: Your custom values (DO NOT commit sensitive data!)
- `vpc.tf`: Network configuration (VPC, subnets, NAT gateway)
- `security-groups.tf`: Security group rules
- `alb.tf`: Application Load Balancer and routing
- `ecs.tf`: ECS cluster, task definitions, and services
- `outputs.tf`: Output values after deployment

## Accessing Your Application

After deployment:

- **Frontend**: `http://<alb-dns-name>`
- **Admin Panel**: `http://<alb-dns-name>/admin`
- **Backend API**: `http://<alb-dns-name>/api`

## Monitoring

- **CloudWatch Logs**: AWS Console → CloudWatch → Log Groups → `/ecs/food-delivery-dev`
- **ECS Services**: AWS Console → ECS → Clusters → `food-delivery-dev-cluster`
- **Load Balancer**: AWS Console → EC2 → Load Balancers

## Cost Estimation

Approximate monthly costs:

- **ECS Fargate**: $50-80
- **ALB**: $20
- **NAT Gateway**: $35
- **EFS**: $5
- **S3**: $1-5
- **Total**: ~$110-150/month

## Cleanup

To destroy all resources and stop incurring charges:

```bash
terraform destroy
```

Type `yes` when prompted.

## Updating the Deployment

To update with new Docker images:

```bash
# Update docker_image_tag in terraform.tfvars
terraform apply -var="docker_image_tag=<new-tag>"
```

## Troubleshooting

### Check ECS Task Status

```bash
aws ecs list-tasks --cluster food-delivery-dev-cluster
aws ecs describe-tasks --cluster food-delivery-dev-cluster --tasks <task-arn>
```

### View Logs

```bash
aws logs tail /ecs/food-delivery-dev --follow
```

### Check Load Balancer Health

```bash
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## Security Considerations

1. **Never commit `terraform.tfvars` with sensitive data to Git**
2. Use AWS Secrets Manager for production deployments
3. Enable HTTPS with AWS Certificate Manager
4. Restrict security groups to specific IP ranges for production
5. Enable AWS WAF for additional protection

## Next Steps

- Add HTTPS support with ACM certificate
- Configure custom domain with Route53
- Enable auto-scaling for ECS services
- Set up CloudWatch alarms for monitoring
- Implement CI/CD pipeline with GitHub Actions
