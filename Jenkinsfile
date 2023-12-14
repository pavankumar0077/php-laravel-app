pipeline {
    agent any

    parameters {
        string(name: 'PHP_VERSION', defaultValue: '8.2.13', description: 'PHP version')
        string(name: 'COMPOSER_VERSION', defaultValue: '2', description: 'Composer version')
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/pavankumar0077/php-laravel-app.git'
            }
        }

        stage('Build') {
            steps {
                // Use PHP container to run build commands
                container("php:${params.PHP_VERSION}") {
                    sh "php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\""
                    sh "php composer-setup.php --install-dir=/usr/local/bin --filename=composer --version=${params.COMPOSER_VERSION}"
                    sh "composer install --no-interaction"
                    sh "php artisan build"
                }
            }
        }

        stage('Run PHP Application') {
            steps {
                // Use PHP container to run PHP application
                container("php:${params.PHP_VERSION}") {
                    sh "php artisan serve --host=0.0.0.0 --port=8001"
                }
            }
        }
    }
}

