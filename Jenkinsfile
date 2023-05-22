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
                        ssh -o StrictHostKeyChecking=no ubuntu@13.233.152.85 whoami
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
                    docker.build("my-lara-app:${env.BUILD_ID}", "-f Dockerfile .")
                }
            }
        }
 
        stage('Test') {
            steps {
                // Run your Laravel application tests within the Docker container
                script {
                    docker.image("my-lara-app:${env.BUILD_ID}")
                        .inside('-w /var/www/html') {
                        sh 'cp .env.example .env' 
                        sh 'composer install --no-interaction --optimize-autoloader --no-ansi --no-scripts --no-progress'
                        sh 'php -d memory_limit=2048M  $(which composer) update'
                        sh 'php artisan key:generate'
                        sh 'composer dump-autoload --optimize'
                        sh 'vendor/bin/phpunit'
                    }
                }
            }    

        }
    }    
    post {
        success {
            sh 'cd "/var/jenkins_home/workspace/lara"'
            sh 'rm -rf artifact.zip'
            sh 'zip -r artifact.zip . -x "*node_modules**"'
            withCredentials([sshUserPrivateKey(credentialsId: "aws-ec2", keyFileVariable: 'keyfile')]) {
                sh 'scp -v -o StrictHostKeyChecking=no -i ${keyfile} /var/jenkins_home/workspace/lara/artifact.zip ubuntu@13.233.152.85:/home/ubuntu/artifact'
            }     
            sshagent(credentials: ['aws-ec2']) {
                sh 'ssh -o StrictHostKeyChecking=no ubuntu@13.233.152.85 "unzip -o /home/ubuntu/artifact/artifact.zip -d /home/ubuntu/artifact"'
                sh 'ssh -o StrictHostKeyChecking=no ubuntu@13.233.152.85 "sudo mv /home/ubuntu/artifact/{*,.*}  /var/www/html"'
                script {
                    try {
                        sh 'ssh -o StrictHostKeyChecking=no ubuntu@13.233.152.85 sudo chmod 777 /var/www/html/storage -R'
                    } catch (Exception e) {
                        echo 'Some file permissions could not be updated.'
                    }
                }
            }
        } 
    } 
}
