#!/bin/bash

function generate_new_certificate() {
    local alias="$1"
    echo "Generating a new self-signed certificate for alias: $alias..."

    # Generate a new key pair and self-signed certificate using keytool
    keytool -genkeypair -v -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -keyalg RSA -keysize $KEY_SIZE -dname "CN=$alias" -alias "$alias" -validity $DAYS_VALID -noprompt

    # Verify that the new certificate has been generated and imported successfully
    keytool -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -list | grep "$alias"

    if [[ $? -eq 0 ]]; then
        echo "New self-signed certificate for alias $alias generated and imported successfully."
    else
        echo "Failed to generate/import new certificate for alias $alias."
        return 1
    fi
}