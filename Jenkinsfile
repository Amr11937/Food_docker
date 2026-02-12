pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = "amr11937"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh "echo \$DOCKERHUB_PASS | docker login -u \$DOCKERHUB_USER --password-stdin"
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                dir('backend') {
                    sh "docker build -t ${DOCKERHUB_REPO}/backend:${BUILD_NUMBER} -t ${DOCKERHUB_REPO}/backend:latest ."
                }
                dir('frontend') {
                    sh "docker build -t ${DOCKERHUB_REPO}/frontend:${BUILD_NUMBER} -t ${DOCKERHUB_REPO}/frontend:latest ."
                }
                dir('admin') {
                    sh "docker build -t ${DOCKERHUB_REPO}/admin:${BUILD_NUMBER} -t ${DOCKERHUB_REPO}/admin:latest ."
                }
            }
        }

        stage('Push Images to Docker Hub') {
            steps {
                sh "docker push ${DOCKERHUB_REPO}/frontend:${BUILD_NUMBER}"
                sh "docker push ${DOCKERHUB_REPO}/frontend:latest"
                sh "docker push ${DOCKERHUB_REPO}/admin:${BUILD_NUMBER}"
                sh "docker push ${DOCKERHUB_REPO}/admin:latest"
                sh "docker push ${DOCKERHUB_REPO}/backend:${BUILD_NUMBER}"
                sh "docker push ${DOCKERHUB_REPO}/backend:latest"
            }
        }

        stage('Deploy to App Server') {
            steps {
                withCredentials([string(credentialsId: 'app-server-ip', variable: 'APP_SERVER_IP')]) {
                    sshagent(credentials: ['app-server-ssh-key']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ec2-user@\$APP_SERVER_IP '
                                cd /home/ec2-user/app

                                # Pull latest images
                                docker-compose pull

                                # Restart all services
                                docker-compose up -d --remove-orphans

                                # Cleanup unused images
                                docker image prune -f

                                # Show running containers
                                docker-compose ps
                            '
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
            cleanWs()
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}