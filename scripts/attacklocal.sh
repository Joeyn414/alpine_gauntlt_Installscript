#!/bin/sh
#This file will pull in the install files, install gauntlt to the container, and then run arachni against the local container. If it finds vulnerabilities the script will return exit 3 otherwise exit 0.
apk update
apk upgrade
apk add git

mkdir -p /opt/security/

if [ -z $START_FOLDER ]; then
        START_FOLDER='/opt/security/'
        echo -e "INFO: setting \$START_FOLDER to '/opt/security/'";
fi

cd $START_FOLDER

git clone https://github.com/Joeyn414/alpine_gauntlt_Installscript.git

#install gauntlt to the alpine container
./alpine_gauntlt_Installscript/scripts/gauntltTestInstall.sh

echo "gauntlt install check initiating..."
cd $START_FOLDER
./alpine_gauntlt_Installscript/scripts/ready_to_rumble.sh
echo "copying arachni attack alias file..."
cp /opt/security/alpine_gauntlt_Installscript/scripts/gauntltattackaliases/arachni.json /usr/lib/ruby/gems/2.2.0/gems/gauntlt-1.0.12/lib/gauntlt/attack_aliases/arachni.json
cd $START_FOLDER
echo "attacking 127.0.0.2..."
gauntlt alpine_gauntlt_Installscript/scripts/arachniattackfiles/arachni-all.attack | tee arachniout.txt
echo "checking the scan results, will exit 3 if we find vulnerabilities"
./alpine_gauntlt_Installscript/scripts/checkvulns.sh arachniout.txt

