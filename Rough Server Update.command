#!/bin/bash

#Written by: Jeremy Black
# This script will download the latest version of the following apps and upload them to the Titan server
    # Google Chrome
    # Firefox
    # Microsoft Office Suite
    # HP Smart

# Variables
    CHROME="https://dl.google.com/chrome/mac/universal/stable/gcem/GoogleChrome.pkg"
    FIREFOX="https://download.mozilla.org/?product=firefox-pkg-latest-ssl&os=osx"
    MS_Office="https://go.microsoft.com/fwlink/p/?linkid=2244846"
    HP_EasyAdmin="https://ftp.hp.com/pub/softlib/software12/HP_Quick_Start/osx/Applications/HP_Easy_Admin.app.zip"
    separator="-------------"
    today=$(date +'%b-%d-%y')

    serverPath="080-fsclusterfs/ITDATA/Field_Techs/Titan"
    logFilePath="zJeremy\ Testing/DownloadLog.txt"
    logToday=$(date +'%b-%d-%y %H:%M:%S %Z')
    open smb://$serverPath || { echo "Error: Failed to connect to Titan Directory. Check network connection and try again."; exit 1; }
    echo "Waiting 5 seconds for server to connect"
     sleep 5

    cd ~/Downloads
# Functions
    Transfer(){
        local fileName="$1"
        local destination="$2"
        local goTo="/Volumes/Titan"

        echo
        echo "transferring $fileName to $goTo/$destination"
        cp -r "$fileName" "$goTo"/"$destination"

        rm "$fileName"
    }


#curl commands
# : << 'END'
    echo $separator"Downloading Chrome"$separator
        # Chrome
            curl -# -L -o Chrome_${today}.pkg $CHROME
    
        Transfer "Chrome_${today}.pkg" Browsers
    echo $separator"Finished Chrome"$separator

    echo
    
    echo $separator"Downloading Firefox"$separator
        # Firefox
            curl -# -L -o Firefox_${today}.pkg $FIREFOX
    
        Transfer "Firefox_${today}.pkg" Browsers
    echo $separator"Finished Firefox" $separator
    
    echo

    echo $separator"Downloading Microsoft Office"$separator
        # MS Office
            curl -# -L -o MS_Office_Install_${today}.pkg $MS_Office
            transfer MS_Office_Install_${today}.pkg Microsoft
    echo $separator"Finished Microsoft Office"$separator
#END
#HP Easy Admin download & Unzip
    curl -O ${HP_EasyAdmin}
        HP_zip=HP_Easy_Admin.app.zip
            unzip $HP_zip
    Transfer 'HP Easy Admin.app' "Printer Drivers"
    rm $HP_zip
echo
echo Completed on: $today



# Uncomment when this is ready to be deployed
    echo "Script completed: $logToday" >> /Volumes/Titan/zJeremy\ Testing/DownloadLog.txt

exit 0
#ideas
    #