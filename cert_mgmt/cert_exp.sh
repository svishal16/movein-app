#!/bin/bash

echo "STARTING CERTIFICATE EXPIRY CHECK SCRIPT"

# Function to check certificate expiry
function check_certificate_expiry() {
    local alias="$1"
    echo "Checking expiry of certificate with alias: $alias"

    # Extract the expiration date of the certificate using keytool
    expiry_date=$(keytool -list -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -alias "$alias" -v | grep "Valid from" | awk -F "until:" '{print $2}')
    echo $expiry_date

    if [[ -z "$expiry_date" ]]; then
        echo "Error: Could not retrieve expiry date for alias $alias."
        return 1
    fi

    expiry_timestamp=$(date -d "$expiry_date" +%s)
    echo $expiry_timestamp

    current_timestamp=$(date +%s)
    echo $current_timestamp

    echo "Certificate with alias $alias expires on: $expiry_date"
    echo "Current date: $(date)"

    # Check if the certificate is expired or will expire within the next 30 days
    if (( expiry_timestamp <= current_timestamp )); then
        echo "Certificate with alias $alias has expired. Renewal is required."
        return 1
    elif (( expiry_timestamp - current_timestamp <= 2592000 )); then
        echo "Certificate with alias $alias will expire in less than 30 days. Renewal is required."
        return 1
    else
        echo "Certificate with alias $alias is valid."
        return 0
    fi
}

function generate_new_certificate() {
    local alias="$1"
    echo "Generating a new self-signed certificate for alias: $alias..."

    # Generate a new key pair and self-signed certificate using keytool
    keytool -genkeypair -v -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -keypass $KEYPASS -keyalg RSA -keysize $KEY_SIZE -dname "CN=$ALIAS_PREFIX, OU=Devops, O=wiz4host, L=Varanasi, ST=UP, C=IN" -alias "$alias" -noprompt

    # Verify that the new certificate has been generated and imported successfully
    keytool -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -list | grep "$alias"

    if [[ $? -eq 0 ]]; then
        echo "New self-signed certificate for alias $alias generated and imported successfully."
    else
        echo "Failed to generate/import new certificate for alias $alias."
        return 1
    fi
}

# Function to renew the certificate
function renew_certificate() {
    local alias="$1"
    echo "Renewing the certificate with alias: $alias..."

    # # Check if the new certificate exists
    # NEW_CERT_FILE="$NEW_CERT_FOLDER/$KEYSTORE"

    # keytool -genkeypair -v -keystore $NEW_CERT_FILE -storepass $STOREPASS -keypass $KEYPASS -dname "$dname" -keyalg RSA -keysize 2048 -alias $alias

    # if [[ ! -f "$NEW_CERT_FILE" ]]; then
    #     echo "New certificate for alias $alias not found at $NEW_CERT_FILE"
    #     return 1
    # fi

    # Back up the old keystore before renewing
    cp $KEYSTORE_DIR/$KEYSTORE "$KEYSTORE_DIR/$KEYSTORE.bkp"

    # Import the new certificate into the JKS file
    # keytool -importcert -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -file "$NEW_CERT_FILE" -alias "$alias" -noprompt

    # Verify that the new certificate has been imported successfully
    keytool -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -list | grep "$alias"

    if [[ $? -eq 0 ]]; then
        echo "Certificate with alias $alias renewed successfully."
    else
        echo "Failed to renew the certificate with alias $alias. Restoring the old keystore."
        mv "$KEYSTORE_DIR/$KEYSTORE.bkp" $KEYSTORE_DIR/$KEYSTORE
        return 1
    fi
}

# Main logic: Iterate through all aliases in the JKS file
aliases=$(keytool -list -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -v | grep "Alias name:" | awk '{print $3}')
echo $aliases

mkdir -p ./cert_mgmt/new_cert

for alias in $aliases
do
    check_certificate_expiry "$alias"
    if [[ $? -ne 0 ]]; then
        generate_new_certificate "$alias"
        renew_certificate "$alias"
    else
        echo "No renewal needed for certificate with alias $alias."
    fi
done
