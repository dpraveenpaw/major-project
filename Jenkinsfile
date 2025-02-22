pipeline {
    agent any
    
    environment {
        DOCKER_COMPOSE_DIR = "${WORKSPACE}"
        TEMPLATE_URL = "https://www.free-css.com/assets/files/free-css-templates/download/page294/troweld.zip"
        COMPOSE_VERSION = "v2.24.1"
    }
    
    stages {
        stage('Install Dependencies') {
            steps {
                script {
                    sh '''
                        # Create local bin directory in workspace
                        mkdir -p ${WORKSPACE}/bin
                        
                        # Download Docker Compose to workspace
                        curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o ${WORKSPACE}/bin/docker-compose
                        
                        # Make it executable
                        chmod +x ${WORKSPACE}/bin/docker-compose
                        
                        # Add to PATH
                        export PATH="${WORKSPACE}/bin:$PATH"
                        
                        # Verify installation
                        ${WORKSPACE}/bin/docker-compose --version
                    '''
                }
            }
        }
        
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Download and Extract Template') {
            steps {
                script {
                    sh '''
                        mkdir -p troweld-html
                        cd troweld-html
                        
                        # Download template
                        curl -L "${TEMPLATE_URL}" -o troweld.zip
                        
                        # Extract template
                        unzip -o troweld.zip
                        
                        # Move files from template directory
                        mv troweld-html/* .
                        rm -rf troweld-html troweld.zip
                    '''
                }
            }
        }
        
        stage('Create Nginx Dockerfile') {
            steps {
                script {
                    writeFile file: 'Dockerfile', text: '''
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy all the static files from troweld-html directory to nginx directory
COPY troweld-html/ /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
'''
                }
            }
        }
        
        stage('Create Docker Compose') {
            steps {
                script {
                    writeFile file: 'docker-compose.yml', text: '''
version: '3.8'

services:
  nginx:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "80:80"
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
'''
                }
            }
        }
        
        stage('Build and Deploy') {
            steps {
                script {
                    sh '''
                        # Add docker-compose to PATH
                        export PATH="${WORKSPACE}/bin:$PATH"
                        
                        # Stop existing containers
                        ${WORKSPACE}/bin/docker-compose down || true
                        
                        # Build and start containers
                        ${WORKSPACE}/bin/docker-compose up -d --build
                    '''
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    sh '''
                        echo "Waiting for services to start..."
                        sleep 30
                        
                        # Check if Nginx is responding
                        if curl -s -f http://localhost:80 > /dev/null; then
                            echo "Nginx is up and running"
                        else
                            echo "Nginx health check failed"
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
                sh '''
                    export PATH="${WORKSPACE}/bin:$PATH"
                    ${WORKSPACE}/bin/docker-compose down || true
                '''
                echo 'Deployment failed!'
            }
        }
        always {
            cleanWs()
        }
    }
}
