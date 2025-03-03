#!/bin/bash

CERT_EXPIRY_THRESHOLD=30
expiry_dates=$(keytool -list -v -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS | grep 'Entry type' | grep 'Cert[0-9]' | awk '{print $3}')

for expiry in $expiry_dates
do
    expiry_timestamp=$(date -d $expiry +%s)
    current_timestamp=$(date +%s)
    days_remaining=$(( (expiry_timestamp - current_timestamp) / 86400 ))
                            
    if (( days_remaining < CERT_EXPIRY_THRESHOLD )); then
        echo "Certificate is expiring in $days_remaining days. It needs to be renewed."
        exit 1
    fi
done



renew_certificate() {
    local alias=$1
    local dname="CN=${alias}, OU=Dev, O=Company, L=City, ST=State, C=US"
    echo "Renewing certificate: $alias"
    # Delete old certificate (renewal process)
    keytool -delete -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -alias $alias
    # Generate new certificate with the same alias
    keytool -genkeypair -v -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -keypass $KEYPASS -dname "$dname" -keyalg RSA -keysize 2048 -alias $alias
}

