pipeline {
    agent any

    environment {
        KEYSTORE_DIR="./cert_mgmt/keystores"
        CERT_DIR="./cert_mgmt/certificates"
        KEYSTORE="test2Keystore.jks"
        STOREPASS="admin123"
        KEYPASS="admin123"
        ALIAS_PREFIX="proj_cert"
        NEW_CERT_FOLDER="./cert_mgmt/new_cert"  
        KEYSTORE_TMP_FILE="keystore_temp.jks"
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


    }
}    
