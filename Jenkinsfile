pipeline {
    agent any

    environment {
        TERRAFORM_VERSION = '0.14.7'
        SSH_KEY = credentials('your-ssh-key')  // Replace 'your-ssh-key' with the actual credential ID for your SSH key
    }

    stages {
        stage('Git Checkout') {
            steps {
                // Checkout the code using git step
                git branch: 'main', url: 'https://github.com/pavankumar0077/php-laravel-app.git'
            }
        }

        stage('Create EC2 Instance with Terraform') {
            steps {
                script {
                    // Download and install Terraform
                    def tfHome = tool 'Terraform'
                    env.PATH = "${tfHome}/bin:${env.PATH}"
                }
                // Navigate to the Terraform folder
                dir('terraform') {
                    // Run Terraform commands
                    sh """
                    terraform init -input=false
                    terraform apply -auto-approve -input=false
                    """
                }
            }
        }

        stage('SSH into EC2 Instance') {
            steps {
                script {
                    // Extract the public IP address from Terraform output
                    def publicIP = sh(script: 'terraform output -json public_ip', returnStdout: true).trim()

                    // SSH into the newly created EC2 instance
                    sh "ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ubuntu@${publicIP} 'echo SSH into EC2 successful'"
                }
            }
        }

        stage('Install Required Packages') {
            steps {
                // SSH into the EC2 instance and install required packages
                script {
                    def commands = """
                    sudo apt-get -y install software-properties-common apt-transport-https git gnupg sudo nano wget curl zip unzip tcl inetutils-ping net-tools
                    sudo add-apt-repository ppa:ondrej/php
                    sudo apt-get install -y php8.2 php8.2-fpm php8.2-bcmath php8.2-curl php8.2-imagick php8.2-intl php-json php8.2-mbstring php8.2-mysql php8.2-xml php8.2-zip
                    sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
                    sudo php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
                    sudo php composer-setup.php
                    sudo php -r "unlink('composer-setup.php');"
                    sudo mv composer.phar /usr/local/bin/composer
                    """
                    sh "ssh -i ${SSH_KEY} ubuntu@${publicIP} '${commands}'"
                }
            }
        }

        stage('Git Checkout Again') {
            steps {
                // SSH into the EC2 instance and checkout the code using git
                script {
                    def commands = """
                    git clone https://github.com/pavankumar0077/php-laravel-app.git
                    """
                    sh "ssh -i ${SSH_KEY} ubuntu@${publicIP} '${commands}'"
                }
            }
        }

        stage('Run Application') {
            steps {
                // SSH into the EC2 instance and run the application
                sh "ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ubuntu@${publicIP} 'cd php-laravel-app && sudo nohup php artisan serve --host=0.0.0.0 --port=8000 &'"
            }
        }
    }

    post {
        always {
            // Sleep for 10 minutes
            sleep time: 10, unit: 'MINUTES'
        }

        success {
            script {
                // Navigate to the Terraform folder
                dir('terraform') {
                    // Run Terraform destroy command
                    sh """
                    terraform destroy -auto-approve
                    """
                }
            }
        }
    }
}

