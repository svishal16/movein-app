pipeline {
    agent any

    environment {
        KEYSTORE_DIR="./cert_mgmt/keystores"
        CERT_DIR="./cert_mgmt/certificates"
        KEYSTORE="test01Keystore.jks"
        STOREPASS="admin123"
        KEYPASS="admin123"
        ALIAS_PREFIX="vishal_dev"
        // NEW_CERT_FOLDER="./cert_mgmt/new_cert"  
        // KEYSTORE_TMP_FILE="keystore_temp.jks"

        registryCredential = 'ecr:us-east-1:awscreds'
        appRegistry = "296062569588.dkr.ecr.us-east-1.amazonaws.com/moveinapp"
        vprofileRegistry = "https://296062569588.dkr.ecr.us-east-1.amazonaws.com"
        cluster = "moveinapp"
        service = "moveinappsvc"
    }

    stages {
   
        stage('Fetch code') {
            steps {
               git branch: 'main', url: 'https://github.com/svishal16/movein-app.git'
            }

        }

        // stage('Install Dependencies') {
        //     steps {
        //         script {
        //             // Install dependencies (e.g., OpenJDK for handling JKS, AWS CLI for certificate renewal)
        //             sh 'sudo apt-get update'
        //             sh 'sudo apt-get install -y openjdk-11-jdk awscli'
        //         }
        //     }
        // }

        stage('Generate Certificates') {
            steps{
                sh 'chmod +x ./cert_mgmt/gen_cert.sh'
                sh './cert_mgmt/gen_cert.sh'
            }
        }

        stage('Checking Certificate Expiry') {
            steps{
                sh 'chmod +x ./cert_mgmt/cert_exp.sh'
                sh './cert_mgmt/cert_exp.sh'
            }
        }

        stage('Build App Image') {
            steps {
                script {
                    echo "Building new Docker image with updated JKS..."
                    dockerImage = docker.build( appRegistry + ":$BUILD_NUMBER", "./Dockerfile")
                }
            }
    
        }

        stage('Upload App Image') {
            steps{
                script {
                    echo "Logging into AWS ECR and Pushing new Docker image..."
                    docker.withRegistry( vprofileRegistry, registryCredential ) {
                        dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Commit Code Changes') {
            steps {
                script {
                    echo "Committing changes to GitHub repository..."
                    sh '''
                        # Make sure any code changes are committed, especially for keystore updates
                        git config user.email "shrivastavavishal640@gmail.com"
                        git config user.name "svishal16"
                        git add $KEYSTORE_DIR/$KEYSTORE
                        git commit -m "Updated JKS with renewed certificate"
                        git push origin main
                    '''
                }
            }
        }

        stage('Remove Container Images') {
            steps{
                sh 'docker rmi -f $(docker images -a -q)'
            }
        }


        stage('Deploy to ecs') {
            steps {
                echo "Deploying to AWS ECS..."
                withAWS(credentials: 'awscreds', region: 'eu-north-1') {
                    sh 'aws ecs update-service --cluster ${cluster} --service ${service} --force-new-deployment'
                }
            }
        }
    }

    post {
        // Clean after build
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                               [pattern: '.propsfile', type: 'EXCLUDE']])
        }
    }
}    
