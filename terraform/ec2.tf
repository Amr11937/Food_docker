# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# ===================== JENKINS SERVER =====================
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.jenkins_instance_type
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update system
              dnf update -y

              # Install Docker
              dnf install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user

              # Install Docker Compose v2
              mkdir -p /usr/local/lib/docker/cli-plugins
              curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o /usr/local/lib/docker/cli-plugins/docker-compose
              chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
              ln -sf /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

              # Install Git
              dnf install -y git

              # Install Java 17 (Jenkins requirement)
              dnf install -y java-17-amazon-corretto

              # Install Jenkins
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              dnf install -y jenkins

              # Add Jenkins user to docker group
              usermod -aG docker jenkins

              # Start Jenkins
              systemctl start jenkins
              systemctl enable jenkins

              # Wait for Jenkins to start and generate password
              sleep 30

              # Save initial admin password for easy access
              cp /var/lib/jenkins/secrets/initialAdminPassword /home/ec2-user/jenkins-password.txt 2>/dev/null || echo "Password not yet generated" > /home/ec2-user/jenkins-password.txt
              chown ec2-user:ec2-user /home/ec2-user/jenkins-password.txt
              EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins"
  }
}

# ===================== APPLICATION SERVER =====================
resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.app_instance_type
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.app.id]
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update system
              dnf update -y

              # Install Docker
              dnf install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user

              # Install Docker Compose v2
              mkdir -p /usr/local/lib/docker/cli-plugins
              curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o /usr/local/lib/docker/cli-plugins/docker-compose
              chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
              ln -sf /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

              # Install Git
              dnf install -y git

              # Create app directory
              mkdir -p /home/ec2-user/app
              chown ec2-user:ec2-user /home/ec2-user/app

              # Create docker-compose.prod.yml
              cat > /home/ec2-user/app/docker-compose.yml <<'COMPOSEFILE'
              version: "3.9"

              services:
                frontend:
                  image: ${var.dockerhub_username}/frontend:latest
                  ports:
                    - "5173:5173"
                  environment:
                    - VITE_API_URL=http://${aws_eip.app.public_ip}:4000
                  depends_on:
                    - backend
                  restart: always

                admin:
                  image: ${var.dockerhub_username}/admin:latest
                  ports:
                    - "5174:5174"
                  environment:
                    - VITE_API_URL=http://${aws_eip.app.public_ip}:4000
                  depends_on:
                    - backend
                  restart: always

                backend:
                  image: ${var.dockerhub_username}/backend:latest
                  ports:
                    - "4000:4000"
                  environment:
                    - PORT=4000
                    - MONGODB_URI=mongodb://${var.mongodb_username}:${urlencode(var.mongodb_password)}@mongo:27017/fooddel?authSource=admin
                    - JWT_SECRET=${var.jwt_secret}
                  depends_on:
                    - mongo
                  restart: always

                mongo:
                  image: mongo:6
                  ports:
                    - "27017:27017"
                  environment:
                    - MONGO_INITDB_ROOT_USERNAME=${var.mongodb_username}
                    - MONGO_INITDB_ROOT_PASSWORD=${var.mongodb_password}
                  volumes:
                    - mongo_data:/data/db
                  restart: always

              volumes:
                mongo_data:
              COMPOSEFILE

              # Fix indentation (heredoc adds spaces)
              sed -i 's/^              //' /home/ec2-user/app/docker-compose.yml

              chown -R ec2-user:ec2-user /home/ec2-user/app

              # Create deploy script
              cat > /home/ec2-user/deploy.sh <<'DEPLOYSCRIPT'
              #!/bin/bash
              cd /home/ec2-user/app
              docker-compose pull
              docker-compose up -d --remove-orphans
              docker image prune -f
              docker-compose ps
              DEPLOYSCRIPT

              chmod +x /home/ec2-user/deploy.sh
              chown ec2-user:ec2-user /home/ec2-user/deploy.sh

              # Pull and start containers
              cd /home/ec2-user/app
              docker compose pull 2>/dev/null || true
              docker compose up -d 2>/dev/null || true
              EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-app"
  }
}

# Elastic IPs (static public IPs)
resource "aws_eip" "jenkins" {
  instance = aws_instance.jenkins.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-eip"
  }
}

resource "aws_eip" "app" {
  instance = aws_instance.app.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-app-eip"
  }
}