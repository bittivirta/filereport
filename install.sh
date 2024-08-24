#!/bin/bash

# License: GPL-3.0-only
# Author: Bittivirta / FI2884270-1
# Full license at /LICENSE

VERSION="1.0"

# Define the URL and target path
SCRIPT_URL="https://raw.githubusercontent.com/bittivirta/filereport/main/filereport.sh"
TARGET_DIR="/usr/local/bin"
TARGET_FILE="$TARGET_DIR/filereport"

# Function to check the HTTP status code
check_response_code() {
    RESPONSE_CODE=$1
    if [ "$RESPONSE_CODE" -ne 200 ] && [ "$RESPONSE_CODE" -ne 304 ] && [ "$RESPONSE_CODE" -ne 301 ] && [ "$RESPONSE_CODE" -ne 302 ] && [ "$RESPONSE_CODE" -ne 307 ] && [ "$RESPONSE_CODE" -ne 308 ]; then
        echo "Error: Failed to download the file. HTTP status code: $RESPONSE_CODE" >&2
        exit 1
    fi
}

# Check for curl or wget to download the script
if command -v curl > /dev/null; then
    DOWNLOADER="curl -w %{http_code} -o"
    GET_RESPONSE_CODE="true"
    RESPONSE_VAR="CURL_RESPONSE_CODE"
elif command -v wget > /dev/null; then
    DOWNLOADER="wget --server-response --output-document"
    GET_RESPONSE_CODE="false"
else
    echo "Error: Neither curl nor wget is installed." >&2
    exit 1
fi

# Download the script
if [ "$GET_RESPONSE_CODE" = "true" ]; then
    CURL_RESPONSE_CODE=$(sudo $DOWNLOADER "$TARGET_FILE" "$SCRIPT_URL")
    check_response_code $CURL_RESPONSE_CODE
else
    sudo $DOWNLOADER "$TARGET_FILE" "$SCRIPT_URL" 2>&1 | grep "HTTP/" | awk '{print $2}' | tee /tmp/wget_response_code
    WGET_RESPONSE_CODE=$(tail -1 /tmp/wget_response_code)
    check_response_code $WGET_RESPONSE_CODE
    rm /tmp/wget_response_code
fi

# Verify that the file was downloaded
if [ ! -f "$TARGET_FILE" ]; then
    echo "Error: The file was not successfully downloaded." >&2
    exit 1
fi

# Make the script executable
sudo chmod +x "$TARGET_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to make the file executable." >&2
    exit 1
fi

# Inform the user of successful installation
echo "filereport has been successfully installed to $TARGET_FILE."
echo "You can now use it as 'filereport filename.zip'."
