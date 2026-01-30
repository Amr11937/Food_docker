pipeline {
    agent any // Assumes Docker is installed on your Jenkins agent/node

    // 1. SET YOUR DOCKER HUB USERNAME HERE mm
    environment {
        DOCKERHUB_REPO = "amr11937" 
    }

    // 2. TRIGGER BLOCK REMOVED
    // This pipeline must be started manually

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm // Gets the code from GitHub
            }
        }

        // 3. LOG IN TO DOCKER HUB
        stage('Login to Docker Hub') {
            steps {
                // Uses the 'dockerhub-creds' credential you'll create in Jenkins
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh "docker login -u ${env.DOCKERHUB_USER} -p ${env.DOCKERHUB_PASS}"
                }
            }
        }

        // 4. BUILD IMAGES SEQUENTIALLY
        stage('Build Docker Images') {
            steps {
                echo "Building frontend image..."
                dir('frontend') { // Change to the 'frontend' directory
                    sh "docker build -t ${env.DOCKERHUB_REPO}/frontend:${env.BUILD_NUMBER} ."
                }
                
                echo "Building admin image..."
                dir('admin') { // Change to the 'admin' directory
                    sh "docker build -t ${env.DOCKERHUB_REPO}/admin:${env.BUILD_NUMBER} ."
                }
                
                echo "Building backend image..."
                dir('backend') { // Change to the 'backend' directory
                    sh "docker build -t ${env.DOCKERHUB_REPO}/backend:${env.BUILD_NUMBER} ."
                }
            }
        }

        

        // 5. PUSH IMAGES SEQUENTIALLY
        stage('Push Images to Docker Hub') {
            steps {
                echo "Pushing frontend image..."
                sh "docker push ${env.DOCKERHUB_REPO}/frontend:${env.BUILD_NUMBER}"

                echo "Pushing admin image..."
                sh "docker push ${env.DOCKERHUB_REPO}/admin:${env.BUILD_NUMBER}"

                echo "Pushing backend image..."
                sh "docker push ${env.DOCKERHUB_REPO}/backend:${env.BUILD_NUMBER}"
            }
        }
    }
}