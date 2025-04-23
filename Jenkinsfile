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
                    sh 'nohup java -jar target/spring-petclinic-3.4.0-SNAPSHOT.jar &'
                    // Spin up the containers
                    sh 'docker-compose -f /var/jenkins_home/docker-compose-ci.yml up --abort-on-container-exit --exit-code-from owasp-zap'

                    // Clean up 
                    sh 'docker-compose -f /var/jenkins_home/docker-compose-ci.yml down'

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
