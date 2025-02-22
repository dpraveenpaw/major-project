pipeline {
    agent any
    
    environment {
        DOCKER_COMPOSE_DIR = "${WORKSPACE}"
        TEMPLATE_URL = "https://www.free-css.com/assets/files/free-css-templates/download/page294/troweld.zip"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Download and Extract Template') {
            steps {
                script {
                    // Create directory and download template
                    sh '''
                        mkdir -p troweld-html
                        cd troweld-html
                        
                        # Download template
                        curl -L "${TEMPLATE_URL}" -o troweld.zip
                        
                        # Install unzip if not present
                        if ! command -v unzip &> /dev/null; then
                            apt-get update && apt-get install -y unzip
                        fi
                        
                        # Extract template
                        unzip -o troweld.zip
                        
                        # Move files from template directory to troweld-html
                        mv troweld-html/* .
                        rm -rf troweld-html troweld.zip
                        
                        # List files
                        ls -la
                    '''
                }
            }
        }
        
        stage('Create Nginx Dockerfile') {
            steps {
                script {
                    sh '''
                        cat > Dockerfile << 'EOF'
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy all the static files from troweld-html directory to nginx directory
COPY troweld-html/ /usr/share/nginx/html/

# Set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF
                    '''
                }
            }
        }
        
        stage('Create Docker Compose') {
            steps {
                script {
                    sh '''
                        cat > docker-compose.yml << 'EOF'
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
    depends_on:
      - jenkins

  jenkins:
    image: jenkins/jenkins:lts
    user: root
    privileged: true
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
    environment:
      - DOCKER_HOST=unix:///var/run/docker.sock
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  jenkins_home:
EOF
                    '''
                }
            }
        }
        
        stage('Build and Deploy') {
            steps {
                script {
                    // Stop existing containers
                    sh 'docker-compose down || true'
                    
                    // Build and start containers
                    sh 'docker-compose up -d --build'
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
                        
                        # Check if Jenkins is responding
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
