#!/bin/bash

# License: GPL-3.0-only
# Author: Bittivirta / FI2884270-1
# Full license at /LICENSE

# Usage: filereport.sh [options] <file_name>
# Options:
#   -v, --version       Show version information
#   -m, --markdown      Output the report in markdown format
#   --help              Show this help message

VERSION="1.0"

show_help() {
    echo "Usage: filereport.sh [options] <file_name>"
    echo "Options:"
    echo "  -v, --version       Show version information"
    echo "  -m, --markdown      Output the report in markdown format"
    echo "  --help              Show this help message"
}

show_version() {
    echo "filereport.sh version $VERSION"
}

check_command() {
    # Check if the command is available
    command -v "$1" &>/dev/null
}

calculate_human_readable_size() {
    SIZE=$1
    # Bytes
    if [ $SIZE -lt 1024 ]; then
        echo "${SIZE} B"
    # Kilobytes
    elif [ $SIZE -lt 1048576 ]; then
        echo "$(echo "scale=2; $SIZE/1024" | bc) KB"
    # Megabytes
    elif [ $SIZE -lt 1073741824 ]; then
        echo "$(echo "scale=2; $SIZE/1048576" | bc) MB"
    # Gigabytes
    elif [ $SIZE -lt 1099511627776 ]; then
        echo "$(echo "scale=2; $SIZE/1073741824" | bc) GB"
    # Terabytes
    else
        echo "$(echo "scale=2; $SIZE/1099511627776" | bc) TB"
    fi
}

initialize_commands() {
    # Define the required commands (all platforms)
    REQUIRED_COMMANDS=("stat" "file" "bc")
    if [[ "$OSTYPE" == "darwin"* ]]; then # macOS
        REQUIRED_COMMANDS+=("md5" "shasum")
    else # Linux and other Unix-like systems
        REQUIRED_COMMANDS+=("md5sum" "sha1sum" "sha256sum" "sha512sum")
    fi
}

check_required_commands() {
    # Create an array to store missing commands
    MISSING_COMMANDS=()
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! check_command "$cmd"; then
            # Add the missing command to the array
            MISSING_COMMANDS+=("$cmd")
        fi
    done

    # Check if any commands are missing and exit if so
    if [ ${#MISSING_COMMANDS[@]} -ne 0 ]; then
        echo "Error: The following commands are required but not installed: ${MISSING_COMMANDS[*]}"
        echo "Please install them and run the script again."
        exit 1
    fi
}

get_checksum() {
    # Calculate the checksums, use the appropriate command based on the OS
    local file=$1
    local os=$2
    if [[ "$os" == "darwin" ]]; then
        MD5=$(md5 "$file" | awk '{print $NF}')
        SHA1=$(shasum -a 1 "$file" | awk '{print $1}')
        SHA256=$(shasum -a 256 "$file" | awk '{print $1}')
        SHA512=$(shasum -a 512 "$file" | awk '{print $1}')
    else
        MD5=$(md5sum "$file" | awk '{print $1}')
        SHA1=$(sha1sum "$file" | awk '{print $1}')
        SHA256=$(sha256sum "$file" | awk '{print $1}')
        SHA512=$(sha512sum "$file" | awk '{print $1}')
    fi
}

report_in_plain_format() {
    # Display the report in plain text format
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
}

report_in_markdown_format() {
    # Display the report in markdown format
    echo "# File report"
    echo ""
    echo "**Original file name:** $FILE_NAME"
    echo ""
    echo "**Original file path:** $FILE"
    echo ""
    echo "**File size:** $FILE_SIZE bytes ($SIZE_HUMAN)"
    echo ""
    echo "**Creation date:** $CREATE_TIME"
    echo ""
    echo "**Last modified:** $MOD_TIME"
    echo ""
    echo "**File type:** $FILE_TYPE"
    echo ""
    # Table cell width is wonky in here, but it's corrected when variables are inserted, as the hash digests are of fixed length
    echo "| Algorithm  | Hash digest                                                                                                                      |"
    echo "|------------|----------------------------------------------------------------------------------------------------------------------------------|"
    echo "| **MD5**    | $MD5                                                                                                 |"
    echo "| **SHA1**   | $SHA1                                                                                         |"
    echo "| **SHA256** | $SHA256                                                                 |"
    echo "| **SHA512** | $SHA512 |"
}

# Main script execution
initialize_commands
check_required_commands

# Check if no arguments are provided
if [ "$#" -eq 0 ]; then
    show_help
    exit 0
fi

# Parse the command line arguments
FORMAT="plain"
FILE=""
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do
    case $1 in
        -v | --version )
            show_version
            exit 0
            ;;
        -m | --markdown )
            FORMAT="markdown"
            ;;
        --help )
            show_help
            exit 0
            ;;
    esac
    shift
done

# Remove the parsed options
if [[ "$1" == '--' ]]; then shift; fi

# Check if a single file name is provided
if [ "$#" -ne 1 ]; then
    echo "Error: Please provide a single file name as an argument." >&2
    exit 1
fi

# Check if the file exists
FILE="$1"

if [ -d "$FILE" ]; then
    echo "Error: The utility supports only single files." >&2
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Error: File not found." >&2
    exit 1
fi

# Get file information
FILE_NAME=$(basename "$FILE")
FILE_SIZE=$(stat -c%s "$FILE" 2>/dev/null || stat -f%z "$FILE")
SIZE_HUMAN=$(calculate_human_readable_size $FILE_SIZE)
FILE_TYPE=$(file --mime-type -b "$FILE")
MOD_TIME=$(stat -c%y "$FILE" 2>/dev/null || stat -f"%Sm" -t "%Y-%m-%d %H:%M:%S" "$FILE")

# Get file creation time
CREATE_TIME="N/A"
if [[ "$OSTYPE" == "darwin"* ]]; then
    CREATE_TIME=$(stat -f%B "$FILE")
    CREATE_TIME=$(date -r $CREATE_TIME "+%Y-%m-%d %H:%M:%S")
else
    CREATE_TIME=$(stat -c%w "$FILE" 2>/dev/null)
    [ "$CREATE_TIME" = "-" ] && CREATE_TIME="N/A"
fi


# Calculate checksums
get_checksum "$FILE" "$OSTYPE"

# Display report in the chosen format
if [ "$FORMAT" == "markdown" ]; then
    report_in_markdown_format
else
    report_in_plain_format
fi

# Exit successfully
exit 0