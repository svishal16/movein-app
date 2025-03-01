pipeline {
    agent any

    environment {
        KEYSTORE_DIR="./cert_mgmt/keystores"
        CERT_DIR="./cert_mgmt/certificates"
        KEYSTORE="myKeystore.jks"
        STOREPASS="admin123"
        KEYPASS="admin123"
        ALIAS_PREFIX="proj_cert"
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
                sh '''
                    local alias=$1
                    local dname="CN=${alias}, OU=Devops, O=wiz4host, L=Varanasi, ST=UP, C=IN"
                    echo "Generating Root Certificate"
	                keytool -genkeypair -v -keystore ./cert_mgmt/keystores/myKeystore.jks -storepass $STOREPASS -keypass $KEYPASS -dname "$dname" -keyalg RSA -keysize 2048 -alias root
	                echo "Generating certificate: $alias"
                    keytool -genkeypair -v -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -keypass $KEYPASS -dname "$dname" -keyalg RSA -keysize 2048 -alias $alias
                    
                    for i in {1..24}; do
                        alias="$ALIAS_PREFIX_$i"
                        generate_certificate $alias
                    done
                '''
            }
        }


    }
}    
