#!/bin/bash
alias=$1

CERT_EXPIRY_THRESHOLD=30
expiry_date=$(keytool -keystore $KEYSTORE_DIR/$KEYSTORE -storepass $STOREPASS -alias "$alias" -v | grep "Valid from" | awk -F "until:" '{print $2}')
echo $expiry_date

for expiry in $expiry_date
do
    expiry_timestamp=$(date -d $expiry +%s)
    current_timestamp=$(date +%s)
    days_remaining=$(( (expiry_timestamp - current_timestamp) / 86400 ))
                            
    if (( days_remaining < CERT_EXPIRY_THRESHOLD )); then
        echo "Certificate is expiring in $days_remaining days. It needs to be renewed."
        exit 1
    fi
done