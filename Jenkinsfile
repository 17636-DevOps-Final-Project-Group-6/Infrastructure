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
                    // Start the webapp in the background
                    sh 'java -jar target/spring-petclinic-3.4.0-SNAPSHOT.jar &'

                    // Request OWASP ZAP SCAN
                    sh '/var/jenkins_home/owasp-zap/script.sh'

                    // Stop the webapp running locally
                    sh '''
                        PID=$(ps aux | grep 'spring-petclinic-3.4.0-SNAPSHOT.jar' | grep -v grep | awk '{print $2}')
                        if [ -n "$PID" ]; then
                            kill $PID
                        fi
                    '''
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
                archiveArtifacts artifacts: '**/owasp-zap/reports/**', allowEmptyArchive: true
            }
        }
    }

    post {
        always {
            junit '**/target/surefire-reports/*.xml'
        }
    }
}
