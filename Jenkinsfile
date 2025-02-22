pipeline {
    agent any
    
    environment {
        DOCKER_COMPOSE_DIR = "${WORKSPACE}"
        NGINX_IMAGE = "nginx:alpine"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Pull Images') {
            steps {
                script {
                    sh "docker pull ${NGINX_IMAGE}"
                    sh "docker pull jenkins/jenkins:lts"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    sh 'docker-compose down || true'
                    sh 'docker-compose up -d'
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    sh '''
                        echo "Waiting for services to start..."
                        sleep 30
                        
                        if curl -s -f http://localhost:80 > /dev/null; then
                            echo "Nginx is up and running"
                        else
                            echo "Nginx health check failed"
                            exit 1
                        fi
                        
                        if curl -s -f http://localhost:8080 > /dev/null; then
                            echo "Jenkins is up and running"
                        else
                            echo "Jenkins health check failed"
                            exit 1
                        fi
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            script {
                sh 'docker-compose down || true'
                echo 'Deployment failed!'
            }
        }
        always {
            cleanWs()
        }
    }
}
