pipeline {
    agent any

    stages {
        stage('Deploy') {
            steps {

                // Build the Docker image
                sh 'docker build -t my-laravel-app .'

               // Run the Docker container with the new image
                sh 'docker run -it -p 8000:80 --name my-laravel-container -d my-laravel-app'
            }
        }
    }
}
