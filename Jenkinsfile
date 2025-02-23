pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'vite-react-app'
        DOCKER_TAG = 'latest'
        PATH = "${tool 'NodeJS14'}/bin:${env.PATH}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }
        
        // ...other stages remain the same...
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
