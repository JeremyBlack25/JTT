#!/bin/bash

#Written by: Jeremy Black
# This script will download the latest version of the following apps and upload them to the Titan server
    # Google Chrome
    # Firefox
    # Microsoft Office Suite
    # HP Easy Admin

# Variables
    #app links & misc
        CHROME="https://dl.google.com/chrome/mac/universal/stable/gcem/GoogleChrome.pkg"
        FIREFOX="https://download.mozilla.org/?product=firefox-pkg-latest-ssl&os=osx"
        MS_Office="https://go.microsoft.com/fwlink/p/?linkid=2244846"
        HP_EasyAdmin="https://ftp.hp.com/pub/softlib/software12/HP_Quick_Start/osx/Applications/HP_Easy_Admin.app.zip"
        separator="-------------"
        today=$(date +'%b-%d-%y')
        logToday=$(date +'%b-%d-%y %H:%M:%S %Z')

    # Server data
        server="080-fsclusterfs"
        shareName="ITDATA"
        userName="jeremy.black"
        logFilePath="zJeremy\ Testing/DownloadLog.txt"

    #serverPath="080-fsclusterfs/ITDATA/Field_Techs/Titan"
    
#Connect to Server (deprecated)
    #open smb://$serverPath || { echo "Error: Failed to connect to Titan Directory. Check network connection and try again."; exit 1; }
    #echo "Waiting 5 seconds for server to connect"
    # sleep 5

#create temp Mount point for server
    mountPoint=$(mktemp -d -t smbMount)
        if [ -z "$mountPoint" ] || [ ! -d "$mountPoint" ]; then
            echo "Error: Failed to create temporary mount directory. Exiting."
            exit 1 # Stop the script

            else
                echo
                echo Success: temp volume created
                echo temp volume: "$mountPoint"
                echo
        fi 
    trap 'umount "$mountPoint"' EXIT INT TERM
# change directory to download files to the local Dowloads folder
    downloads=~/Downloads
        cd $downloads || { echo "Error: Failed to change Directory to $downloads"; exit 1
            }
#mount 080-fsclusterfs to the temp mount location

    read -p "Please enter your SMB username: " smb_username
    read -s -p "Please enter your SMB password: " smb_password
    echo # Add a newline after the silent input prompt

     mount_smbfs -v "//$smb_username:$smb_password@$server/$shareName/Field_Techs/Titan" "$mountPoint" || {
        echo "Error: Failed to mount the server share. Check credentials, network or network path."
        exit 1 # Stop the script if mounting fails
    }
    
        
# Functions
    Transfer() {
        local fileName="$1"
        local destination="$2"
        local URL="$3"
        local goTo=$mountPoint #"/Volumes/Titan"


        echo
        echo "$separator Downloading $fileName $separator"

        curl -# -L -o "$fileName" "$URL"
            mkdir $goTo/$destination
        echo
        echo "transferring $fileName to $goTo/$destination"
        cp "$fileName" "$goTo/$destination" || {echo "ERROR: Failed to copy $fileName to $destination. Please check that the server is active, permissions are correct, and files exist in $downloads." exit 1 }
            #cp ~/Desktop/command.txt "$goTo/$destination/name"
        rm -r "$fileName" || {echo "filed to remove $filename" exit 1 }
        echo
        echo "$separator Completed $fileName $separator"

        pwd
    }

#curl commands
        #Chrome            
            Transfer "Chrome_${today}.pkg" Browsers $CHROME
    echo
: << 'END'
        #firefox            
            Transfer "Firefox_${today}.pkg" Browsers $FIREFOX
    echo
        #Microsoft Office
            Transfer MS_Office_Install_${today}.pkg Microsoft $MS_Office
    echo

        #HP Easy Admin download & Unzip
            curl -O ${HP_EasyAdmin}
                HP_zip=HP_Easy_Admin.app.zip
                    unzip $HP_zip
            #Transfer 'HP Easy Admin.app' "Printer Drivers" $HP_EasyAdmin
            rm $HP_zip
    echo
echo Completed on: $today
END

# Uncomment when this is ready to be deployed
    #echo "Script completed: $logToday" >> /Volumes/Titan/zJeremy\ Testing/DownloadLog.txt

exit 0
#ideas
    #