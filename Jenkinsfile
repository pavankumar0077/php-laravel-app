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
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/pavankumar0077/php-laravel-app.git'
            }
        }

        stage('Terraform init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Plan') {
            steps {
                sh 'terraform plan -out tfplan'
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Apply / Destroy') {
            steps {
                script {
                    if (params.action == 'apply') {
                        if (!params.autoApprove) {
                            def plan = readFile 'tfplan.txt'
                            input message: "Do you want to apply the plan?",
                            parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                        }

                        sh 'terraform apply -input=false tfplan'
                    } else if (params.action == 'destroy') {
                        sh 'terraform destroy --auto-approve'
                    } else {
                        error "Invalid action selected. Please choose either 'apply' or 'destroy'."
                    }
                }
            }
        }

        stage('Sleep for 1 minute') {
            steps {
                sleep time: 60, unit: 'SECONDS'
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

        
    //     stage('Prerequisites & Essential Tools') {
    //         steps {
    //             // Update & Upgrade non-interactively
    //             sh 'sudo DEBIAN_FRONTEND=noninteractive apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y'

    //             // OS essential tools
    //             sh 'sudo apt-get -y install software-properties-common apt-transport-https git gnupg sudo nano wget curl zip unzip tcl inetutils-ping net-tools'

    //             // PHP & its required extensions
    //             sh 'sudo add-apt-repository ppa:ondrej/php'
    //             sh 'sudo apt-get install -y php8.2 php8.2-fpm php8.2-bcmath php8.2-curl php8.2-imagick php8.2-intl php-json php8.2-mbstring php8.2-mysql php8.2-xml php8.2-zip'

    //             // Composer installation to build and run the project
    //             sh '''sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"'''
    //             sh '''sudo php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"'''
    //             sh 'sudo php composer-setup.php'
    //             sh '''sudo php -r "unlink('composer-setup.php');"'''
    //             sh 'sudo mv composer.phar /usr/local/bin/composer'

    //             // Install Git
    //             sh 'sudo apt install -y git'
    //         }
    //     }

        
    //     stage('Git Checkout Again') {
    //         steps {
    //             // SSH into the EC2 instance and checkout the code using git
    //             script {
    //                 def commands = """
    //                 git clone https://github.com/pavankumar0077/php-laravel-app.git
    //                 """
    //                 sh "ssh -i ${SSH_KEY} ubuntu@${publicIP} '${commands}'"
    //             }
    //         }
    //     }

    //     stage('Run Application') {
    //         steps {
    //             // SSH into the EC2 instance and run the application
    //             sh "ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ubuntu@${publicIP} 'cd php-laravel-app && sudo nohup php artisan serve --host=0.0.0.0 --port=8000 &'"
    //         }
    //     }
    // }
}






