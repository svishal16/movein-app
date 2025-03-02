#!/bin/bash

# KEYSTORE_DIR="./cert_mgmt/keystores"
# CERT_DIR="./cert_mgmt/certificates"
# KEYSTORE="testbKeystore.jks"
# STOREPASS="admin123"
# KEYPASS="admin123"
# ALIAS_PREFIX="proj_cert"

mkdir -p ./cert_mgmt/certificates
mkdir -p ./cert_mgmt/keystores

echo "Generating Root Certificate"
keytool -genkeypair -v -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -keypass $KEYPASS -dname "CN=$ALIAS_PREFIX, OU=Devops, O=wiz4host, L=Varanasi, ST=UP, C=IN" -keyalg RSA -keysize 2048 -alias root

function generate_certificate() {
    local alias=$1
    local dname="CN=${alias}, OU=Devops, O=wiz4host, L=Varanasi, ST=UP, C=IN"
    echo "Generating certificate: $alias"
    keytool -genkeypair -v -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -keypass $KEYPASS -dname "$dname" -keyalg RSA -keysize 2048 -alias $alias
}

for i in {1..24}
do
    alias="${ALIAS_PREFIX}_${i}"
    generate_certificate $alias
done