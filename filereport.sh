#!/bin/bash

# License: GPL-3.0-only
# Author: Bittivirta / FI2884270-1
# Full license at /LICENSE

# Usage: filereport.sh <file_name>

if [ "$#" -ne 1 ]; then
    echo "Error: Please provide a single file name as an argument."
    exit 1
fi

FILE="$1"

if [ -d "$FILE" ]; then
    echo "Error: The utility supports only single files." >&2
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Error: File not found." >&2
    exit 1
fi

FILE_NAME=$(basename "$FILE")
FILE_SIZE=$(stat -c%s "$FILE" 2>/dev/null || stat -f%z "$FILE")

# Function to calculate human-readable file size
calculate_human_readable_size() {
    SIZE=$1
    if [ $SIZE -lt 1024 ]; then
        echo "${SIZE} B"
    elif [ $SIZE -lt 1048576 ]; then
        echo "$(echo "scale=2; $SIZE/1024" | bc) KB"
    elif [ $SIZE -lt 1073741824 ]; then
        echo "$(echo "scale=2; $SIZE/1048576" | bc) MB"
    else
        echo "$(echo "scale=2; $SIZE/1073741824" | bc) GB"
    fi
}

SIZE_HUMAN=$(calculate_human_readable_size $FILE_SIZE)

# File time information
MOD_TIME=$(stat -c%y "$FILE" 2>/dev/null || stat -f"%Sm" -t "%Y-%m-%d %H:%M:%S" "$FILE")

# File creation time
CREATE_TIME="N/A"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CREATE_TIME=$(stat -f%B "$FILE")
    CREATE_TIME=$(date -r $CREATE_TIME "+%Y-%m-%d %H:%M:%S")
else
    # Linux
    CREATE_TIME=$(stat -c%w "$FILE" 2>/dev/null)
    if [ "$CREATE_TIME" = "-" ]; then
        CREATE_TIME="N/A"
    fi
fi

# File type information
FILE_TYPE=$(file --mime-type -b "$FILE")

# Calculate checksums directly on the file and extract hash only
if [[ "$OSTYPE" == "darwin"* ]]; then
    MD5=$(md5 "$FILE" | awk '{print $NF}')
    SHA1=$(shasum -a 1 "$FILE" | awk '{print $1}')
    SHA256=$(shasum -a 256 "$FILE" | awk '{print $1}')
    SHA512=$(shasum -a 512 "$FILE" | awk '{print $1}')
else
    MD5=$(md5sum "$FILE" | awk '{print $1}')
    SHA1=$(sha1sum "$FILE" | awk '{print $1}')
    SHA256=$(sha256sum "$FILE" | awk '{print $1}')
    SHA512=$(sha512sum "$FILE" | awk '{print $1}')
fi

# Display report
echo "File report"
echo ""
echo "Original file name:"
echo "$FILE_NAME"
echo ""
echo "Original file path:"
echo "$FILE"
echo ""
echo "File size:"
echo "$FILE_SIZE bytes ($SIZE_HUMAN)"
echo ""
echo "Creation date:"
echo "$CREATE_TIME"
echo ""
echo "Last modified:"
echo "$MOD_TIME"
echo ""
echo "File type:"
echo "$FILE_TYPE"
echo ""
echo "Algorithm   Hash digest"
echo "MD5         $MD5"
echo "SHA1        $SHA1"
echo "SHA256      $SHA256"
echo "SHA512      $SHA512"
