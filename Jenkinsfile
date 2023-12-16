pipeline {
    agent any

    parameters {
    booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        SSH_KEY               = credentials('SSH_KEY')  
        PHP_PATH              = '/usr/bin/php'  // Added PHP_PATH
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/pavankumar0077/php-laravel-app.git'
            }
        }

        stage('Terraform init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Sleep for 1 minute') {
            steps {
                sleep time: 60, unit: 'SECONDS'
            }
        }

        stage('SSH into EC2 instance') {
            steps {
                script {
                    // Extract the public IP address from Terraform output
                    def publicIP = sh(script: 'terraform output -json public_ip', returnStdout: true).trim()

                    // SSH into the newly created EC2 instance
                    sh "ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ubuntu@${publicIP}"
                }
            }
        }

        stage('Prerequisites & Essential Tools') {
            environment {
                DEBIAN_FRONTEND = 'noninteractive'
            }
            steps {
                sh 'sudo apt update'
                sh 'sudo apt-get -y install software-properties-common apt-transport-https git gnupg sudo nano wget curl zip unzip tcl inetutils-ping net-tools'
                sh 'sudo add-apt-repository ppa:ondrej/php'
                sh 'sudo apt-get install -y php8.2 php8.2-fpm php8.2-bcmath php8.2-curl php8.2-imagick php8.2-intl php-json php8.2-mbstring php8.2-mysql php8.2-xml php8.2-zip'
                sh '''sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"'''
                sh '''sudo php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"'''
                sh 'sudo php composer-setup.php'
                sh '''sudo php -r "unlink('composer-setup.php');"'''
                sh 'sudo mv composer.phar /usr/local/bin/composer'
                sh 'sudo apt install -y git'
                sh 'sudo apt install -y php-cli'
            }
        }

        stage('Git Checkout Again') {
            steps {
                script {
                    // Extract the public IP address from Terraform output
                    def publicIP = sh(script: 'terraform output -json public_ip', returnStdout: true).trim()

                    // SSH into the newly created EC2 instance and checkout the code using git
                    sh "ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ubuntu@${publicIP} 'git clone https://github.com/pavankumar0077/php-laravel-app.git'"
                }
            }
        }

        stage('Sleep for 45 seconds') {
            steps {
                sleep time: 45, unit: 'SECONDS'
            }
        }

        stage('Run Application') {
            steps {
                script {
                    // Extract the public IP address from Terraform output
                    def publicIP = sh(script: 'terraform output -json public_ip', returnStdout: true).trim()

                    // SSH into the newly created EC2 instance and start the application
                    sh "ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ubuntu@${publicIP} 'cd php-laravel-app && composer install && cp .env.example .env && php artisan key:generate && php artisan serve --host=0.0.0.0 --port=80'"
                }
            }
        }
    }
}
