pipeline {
    agent any

    tools {
        maven 'Maven 3.8.1'
        jdk 'jdk-17'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-creds',
                    url: 'https://github.com/17636-DevOps-Final-Project-Group-6/spring-petclinic.git'
            }
        }
        
        stage('Build') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("Sonar") {
                    sh  './mvnw sonar:sonar -Dsonar.projectKey=DevSonar'
                }
            }
        }

        stage('Run OWASP ZAP CI Scan') {
            steps {
                script {
                    // Spin up the containers
                    sh 'docker-compose -f /var/jenkins_home/docker-compose-ci.yml up --abort-on-container-exit --exit-code-from owasp-zap'

                    // Clean up 
                    sh 'docker-compose -f /var/jenkins_home/docker-compose-ci.yml down'
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
                archiveArtifacts artifacts: '**/zap-reports/**', allowEmptyArchive: true
            }
        }
    }

    post {
        always {
            junit '**/target/surefire-reports/*.xml'
        }
    }
}
