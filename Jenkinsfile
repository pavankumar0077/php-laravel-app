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

        stage('Sleep for 2 minutes') {
            steps {
                sleep time: 120, unit: 'SECONDS'
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

        stage('Install Dependencies') {
            steps {
                script {
                    def ip = sh(script: "terraform output public_ip", returnStdout: true).trim()

                    sshagent(['SSH_KEY']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@\$ip "
                                sudo apt update &&
                                sudo apt install -y software-properties-common &&
                                sudo add-apt-repository ppa:ondrej/php &&
                                sudo apt install -y php php-common php-mbstring php-xmlrpc php-soap php-gd php-xml php-intl php-mysql php-cli php-zip php-curl &&
                                curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
                            "
                        """
                    }
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
}






