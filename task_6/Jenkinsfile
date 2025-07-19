pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials-id'
        SONAR_TOKEN_ID = 'sonarqube-token-id'
        KUBE_CONFIG_ID = 'kubeconfig'


        AWS_ACCOUNT_ID = 'aws'
        AWS_REGION = 'eu-central-1'
        ECR_REPO_NAME = 'spring-app'
        DOCKER_IMAGE_BASE_NAME = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
    }

    tools {
        maven 'Maven3'
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Suxita/CI-CD-with-jenkins'
            }
        }

        stage('2. Build Application') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('3. Unit Tests') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('4. SonarQube Security Scan') {
            steps {
                withCredentials([string(credentialsId: "${SONAR_TOKEN_ID}", variable: 'SONAR_LOGIN_TOKEN')]) {
                    withSonarQubeEnv('SonarQube') { // 'SonarQube' must be configured under Manage Jenkins -> System -> SonarQube servers
                        sh """
                            mvn sonar:sonar \
                            -Dsonar.projectKey=spring-app \
                            -Dsonar.host.url=http://18.194.239.38:9000 \
                            -Dsonar.login=${SONAR_LOGIN_TOKEN}
                        """
                    }
                }
            }
        }

        stage('5. Build & Push Docker Image') {
            steps {
                script {
                    def imageTag = "${DOCKER_IMAGE_BASE_NAME}:${env.BUILD_NUMBER}"
                    def latestImageTag = "${DOCKER_IMAGE_BASE_NAME}:latest"


                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                    docker.build(imageTag, ".") // "." specifies the build context is current directory

                    docker.push(imageTag)

                    docker.push(latestImageTag)
                }
            }
        }

        stage('6. Deploy to K8s with Helm') {
            steps {
                script {
                    withCredentials([file(credentialsId: "${KUBE_CONFIG_ID}", variable: 'KUBECONFIG_PATH')]) {
                        sh "export KUBECONFIG=${KUBECONFIG_PATH}"

                        sh 'kubectl config current-context'
                        sh 'kubectl get nodes'

                        sh """
                            helm upgrade --install spring-app ./helm \
                                --namespace default \
                                --set image.repository=${DOCKER_IMAGE_BASE_NAME} \
                                --set image.tag=latest \
                                --wait \
                                --timeout 5m
                        """

                    }
                }
            }
        }

       stage('7. Application Verification') {
            steps {
                sleep time: 30, unit: 'SECONDS' // Give some time for deployment to settle
                script {

                    def nodePort = sh(script: "kubectl get service spring-app -n default -o jsonpath='{.spec.ports[0].nodePort}'", returnStdout: true).trim()


                    def nodeIp = sh(script: "hostname -I | awk '{print \$1}'", returnStdout: true).trim() // Gets private IP

                    def appUrl = "http://${nodeIp}:${nodePort}"

                    echo "Attempting to verify application at ${appUrl}"


                    retry(5) { // Retry up to 5 times
                        sh "curl --fail --silent --show-error --connect-timeout 10 ${appUrl}"
                        echo "Application responded successfully at ${appUrl}"
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                def jobStatus = currentBuild.result ?: 'SUCCESS'
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def buildUrl = env.BUILD_URL
                def subject = "${jobStatus}: Jenkins Job '${jobName}' #${buildNumber}"
                def body = """
                    <p>Job: <a href='${buildUrl}'>${jobName}</a> #${buildNumber}</p>
                    <p>Status: <strong>${jobStatus}</strong></p>
                """
                emailext (
                    subject: subject,
                    body: body,
                    to: 'mishosukhishvili@gmail.com',
                    mimeType: 'text/html'
                )
            }
        }
    }
}