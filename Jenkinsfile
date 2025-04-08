pipeline {
    agent {
        docker {
            image 'maven:3.8.6-openjdk-17'
            args '-v /root/.m2:/root/.m2'
        }
    }

    environment {
        SONAR_HOST_URL = 'http://sonarqube:9000'
        SONAR_LOGIN = credentials('sonarqube-token')
        ZAP_API_URL = 'http://owasp-zap:8090'
        ZAP_API_KEY = 'apikey'
        APP_NAME = 'spring-petclinic'
        APP_PORT = '8080'
        PRODUCTION_SERVER = 'production-server'
    }

    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                    mvn sonar:sonar \
                      -Dsonar.host.url=${SONAR_HOST_URL} \
                      -Dsonar.login=${SONAR_LOGIN} \
                      -Dsonar.projectKey=${APP_NAME} \
                      -Dsonar.projectName=${APP_NAME} \
                      -Dsonar.sourceEncoding=UTF-8
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Package & Docker Build') {
            steps {
                sh 'mvn package -DskipTests'
                sh """
                docker build -t ${APP_NAME}:${BUILD_NUMBER} \
                  --build-arg JAR_FILE=target/*.jar .
                """
            }
        }

        stage('Security Scan with OWASP ZAP') {
            steps {
                sh """
                # Start application for testing
                docker run -d --name ${APP_NAME}-${BUILD_NUMBER} -p ${APP_PORT}:${APP_PORT} ${APP_NAME}:${BUILD_NUMBER}
                
                # Wait for application to start
                sleep 30
                
                # Run ZAP scan
                curl -k "${ZAP_API_URL}/JSON/spider/action/scan/?apikey=${ZAP_API_KEY}&url=http://host.docker.internal:${APP_PORT}/"
                sleep 60
                curl -k "${ZAP_API_URL}/JSON/ascan/action/scan/?apikey=${ZAP_API_KEY}&url=http://host.docker.internal:${APP_PORT}/"
                sleep 120
                
                # Export HTML report
                mkdir -p zap-reports
                curl -k "${ZAP_API_URL}/OTHER/core/other/htmlreport/?apikey=${ZAP_API_KEY}" > zap-reports/zap-report-${BUILD_NUMBER}.html
                
                # Stop application
                docker stop ${APP_NAME}-${BUILD_NUMBER}
                docker rm ${APP_NAME}-${BUILD_NUMBER}
                """
                
                publishHTML(target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'zap-reports',
                    reportFiles: "zap-report-${BUILD_NUMBER}.html",
                    reportName: 'ZAP Security Report'
                ])
            }
        }

        stage('Deploy to Production') {
            steps {
                ansiblePlaybook(
                    playbook: 'ansible/deploy.yml',
                    inventory: 'ansible/inventory',
                    extras: "-e app_name=${APP_NAME} -e app_version=${BUILD_NUMBER}"
                )
            }
        }
    }

    post {
        always {
            // Clean up any remaining containers
            sh "docker ps -a | grep ${APP_NAME} | awk '{print \$1}' | xargs -r docker rm -f"
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
} 