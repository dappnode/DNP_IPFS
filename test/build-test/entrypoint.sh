#!/bin/sh

echo "Sleeping 30s to allow IPFS daemon inizialization..."
sleep 30

# Before test
FILE_PATH=hello.txt
echo "DAppNodeIsAwesome" > $FILE_PATH

# Test add
HASH=$(curl -F file=@${FILE_PATH} "http://${IPFS_IP}:5001/api/v0/add" | jq -r '.Hash')
if [ -z "$HASH" ]
then
    echo "HASH receibed after adding file is empty"
    exit 1
else
    echo "Added $FILE_PATH, HASH: $HASH"
fi

# Test cat
FILE=$(curl "http://${IPFS_IP}:5001/api/v0/object/data?arg=${HASH}")
if [ -z "$FILE" ]
then
    echo "FILE receibed after catting HASH $HASH is empty"
    exit 1
else
    # Should compare this two to verify it's the correct output
    # But the string I get is completely uncomparable, and nothing works
    echo "Received file from HASH: $HASH"
    echo "${FILE}" | awk '/DAppNodeIsAwesome/{exit 0} !/DAppNodeIsAwesome/{exit 1}' ;
    if [ "$?" = "0" ]
    then
        echo "File contains expected string"
    else
        echo "File DOES NOT contain expected string"
        echo "Expected:  DAppNodeIsAwesome"
        echo "Received:  ${FILE}"
        exit 1
    fi
fi


