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
                        ssh -o StrictHostKeyChecking=no ubuntu@43.204.144.148 whoami
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
            sh 'cd "/var/jenkins_home/workspace/elox-pipeline"'
            sh 'rm -rf artifact.zip'
            sh 'zip -r artifact.zip . -x "*node_modules**"'
            withCredentials([sshUserPrivateKey(credentialsId: "aws-ec2", keyFileVariable: 'keyfile')]) {
                sh 'scp -v -o StrictHostKeyChecking=no -i ${keyfile} /var/jenkins_home/workspace/elox-pipeline/artifact.zip ubuntu@43.204.144.148:/home/ubuntu/artifact'
            }     
            sshagent(credentials: ['aws-ec2']) {
                sh 'ssh -o StrictHostKeyChecking=no ubuntu@43.204.144.148 "unzip -o /home/ubuntu/artifact/artifact.zip -d ./var/www/html"'              
                script {
                    try {
                        sh 'ssh -o StrictHostKeyChecking=no ubuntu@43.204.144.148 sudo chmod 777 /var/www/html/storage -R'
                    } catch (Exception e) {
                        echo 'Some file permissions could not be updated.'
                    }
                }
            }
        } 
    } 
}
