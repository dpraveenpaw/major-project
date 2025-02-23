pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'vite-react-app'
        DOCKER_TAG = 'latest'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                // Run npm commands within the NodeJS environment
                nodejs('NodeJS14') {
                    sh 'npm install'
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                nodejs('NodeJS14') {
                    sh 'npm run lint'
                }
            }
        }
        
        stage('Build') {
            steps {
                nodejs('NodeJS14') {
                    sh 'npm run build'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    sh """
                        docker stop ${DOCKER_IMAGE} || true
                        docker rm ${DOCKER_IMAGE} || true
                        docker run -d --name ${DOCKER_IMAGE} -p 8080:80 ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
