pipeline {
    agent any

    parameters {
        string(name: 'PHP_VERSION', defaultValue: '8.2.13', description: 'PHP version')
        string(name: 'COMPOSER_VERSION', defaultValue: '2', description: 'Composer version')
        // string(name: 'PROJECT_FOLDER', defaultValue: 'php-laravel-app', description: 'Folder containing the Laravel project')
    }

    stages {
        stage('Git Checkout') {
            steps {
                // Checkout the code using git step
                git branch: 'main', url: 'https://github.com/pavankumar0077/php-laravel-app.git'
            }
        }

        // stage('Build') {
        //     steps {
        //         // Use PHP container to run build commands
        //         container("php:${params.PHP_VERSION}") {
        //             sh "php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\""
        //             sh "php composer-setup.php --install-dir=/usr/local/bin --filename=composer --version=${params.COMPOSER_VERSION}"
        //             sh "composer install --no-interaction"
        //             sh "php artisan build"
        //         }
        //     }
        // }

        stage('Deploy Project') {
            steps {
                // Deploy the project, making the folder configurable
                // sh "cd sample-app && sudo nohup php artisan serve --host=0.0.0.0 --port=8000 &"
                sh "php artisan serve--host=0.0.0.0 --port=8000"
            }
        }
    }
}

