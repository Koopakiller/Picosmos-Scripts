#!/bin/bash

echo -n "Altair Username: "
read altairUsername

echo -n "Altair User Id: "
read altairUserid

echo -n "Altair Password: "
read -s altairPassword

echo ""

function altairMount {
    mkdir -p ~/Altair/$1
    echo "mounting //altair/$1"
    mount -t cifs -o user="$altairUsername,password=$altairPassword,uid=$altairUserid,vers=3.0" //altair/$1 ~/Altair/$1
}

altairMount Audio
altairMount Video
altairMount Home
altairMount Azure
altairMount AmazonCloudDrive
