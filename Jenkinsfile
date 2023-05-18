pipeline {
    agent any

    stages {
        stage('Deploy') {
            steps {

                // Build the Docker image
                sh 'docker build -t my-laravel-app .'

                // Stop and remove the existing container if running
                sh 'docker stop my-laravel-container || true'
                sh 'docker rm my-laravel-container || true'

                // Run the Docker container with the new image
                sh 'docker run -p 8000:80 --name my-laravel-container -d my-laravel-app'
            }
        }
    }
}
