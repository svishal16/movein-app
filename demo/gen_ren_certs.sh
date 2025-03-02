#!/bin/bash

# Configuration variables
KEYSTORE_DIR=./cert_mgmt/keystores
CERT_DIR=./cert_mgmt/certificates
KEYSTORE="myKeystore.jks"
STOREPASS="admin123"
KEYPASS="admin123"
ALIAS_PREFIX="proj_cert"

# Function to generate a new self-signed certificate
generate_certificate() {
    local alias=$1
    local dname="CN=${alias}, OU=Devops, O=wiz4host, L=Varanasi, ST=UP, C=IN"
    echo "Generating Root Certificate"
	keytool -genkeypair -v -keystore ./cert_mgmt/keystores/myKeystore.jks -storepass $STOREPASS -keypass $KEYPASS -dname "$dname" -keyalg RSA -keysize 2048 -alias root
	echo "Generating certificate: $alias"
    keytool -genkeypair -v -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -keypass $KEYPASS -dname "$dname" -keyalg RSA -keysize 2048 -alias $alias
}

# Function to renew a certificate (create a new self-signed certificate)
renew_certificate() {
    local alias=$1
    local dname="CN=${alias}, OU=Dev, O=Company, L=City, ST=State, C=US"
    echo "Renewing certificate: $alias"
    # Delete old certificate (renewal process)
    keytool -delete -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -alias $alias
    # Generate new certificate with the same alias
    keytool -genkeypair -v -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -keypass $KEYPASS -dname "$dname" -keyalg RSA -keysize 2048 -alias $alias
}

# Function to export certificate to a file
export_certificate() {
    local alias=$1
    local filename=$CERT_DIR/$alias.cer
    echo "Exporting certificate: $alias to $filename"
    keytool -exportcert -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -alias $alias -file $filename
}

# Generate certificates (you can loop to generate multiple)
for i in {1..24}; do
    alias="$ALIAS_PREFIX_$i"
    generate_certificate $alias
done

# Example: renew a specific certificate (uncomment to renew a certificate)
# renew_certificate "dev_cert_1"

# Export all certificates
for i in {1..24}; do
    alias="$ALIAS_PREFIX_$i"
    export_certificate $alias
done

echo "Certificate management complete."
