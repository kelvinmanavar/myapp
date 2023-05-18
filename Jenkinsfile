pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                // Install dependencies and build Laravel app
                sh 'curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer'
                sh 'composer install --no-interaction --no-dev --prefer-dist'
                sh 'cp .env.example .env'
                sh 'php artisan key:generate'
            }
        }

        stage('Deploy') {
            steps {
                // Copy the Nginx configuration file
                sh 'cp nginx.conf /etc/nginx/conf.d/default.conf'

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
