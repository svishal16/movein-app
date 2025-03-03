#!/bin/bash
alias=$1

renew_certificate() {
    local alias=$1
    local dname="CN=${alias}, OU=Dev, O=Company, L=City, ST=State, C=US"
    echo "Renewing certificate: $alias"
    # Delete old certificate (renewal process)
    keytool -delete -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -alias $alias
    # Generate new certificate with the same alias
    keytool -genkeypair -v -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -keypass $KEYPASS -dname "$dname" -keyalg RSA -keysize 2048 -alias $alias
}

