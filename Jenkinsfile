pipeline {
    agent any
    stages {
        stage("Verify tooling") {
            steps {
                sh '''
                    docker info
                    docker version
                    docker compose version
                '''
            }
        }
        stage("Verify SSH connection to server") {
            steps {
                sshagent(credentials: ['aws-ec2']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@13.233.36.155 whoami
                    '''
                }
            }
        }   

        stage("Clear all running docker containers") {
            steps {
                script {
                    try {
                        sh 'docker rm -f $(docker ps -a -q)'
                    } catch (Exception e) {
                        echo 'No running container to clear up...'
                    }
                }
            }
        }

        stage('Build') {
            steps {
                // Build the Docker image
                script {
                    docker.build("my-laravel-app:${env.BUILD_ID}", "-f Dockerfile .")
                }
            }
        }

        stage('Test') {
            steps {
                // Run your Laravel application tests within the Docker container
                script {
                    docker.image("my-laravel-app:${env.BUILD_ID}")
                        .inside('-w /var/www/html') {
                        sh 'composer install --no-interaction --no-ansi --no-scripts --no-progress'
                        sh 'php artisan key:generate'
                        sh 'vendor/bin/phpunit'
                    }
                }
            }    

        }
    }    
    post {
        success {
            sh 'cd "/var/jenkins_home/workspace/eloxlaravel-pipeline"'
            sh 'rm -rf artifact.zip'
            sh 'zip -r artifact.zip . -x "*node_modules**"'
            withCredentials([sshUserPrivateKey(credentialsId: "aws-ec2", keyFileVariable: 'keyfile')]) {
                sh 'scp -v -o StrictHostKeyChecking=no -i ${keyfile} /var/jenkins_home/workspace/eloxlaravel-pipeline/artifact.zip ubuntu@13.233.36.155:/home/ubuntu/artifact'
            }
        }
    } 
}
