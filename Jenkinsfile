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
        
        // stage('Test') {
        //     steps {
        //         sh 'mvn test'
        //     }
        // }
        
        stage('SonarQube Analysis') {
            steps {
                // echo "SONAR_TOKEN: ${SONAR_TOKEN}"
                withSonarQubeEnv("Sonar") {
                    sh  './mvnw sonar:sonar -Dsonar.projectKey=DevSonar'
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
            }
        }
    }

    post {
        always {
            junit '**/target/surefire-reports/*.xml'
        }
    }
}
