#!/bin/sh
#
#@author: Joe Niquette
#@version: 0.1 6/28/16
#@Contributors: Andrew Rottier, Florian Orleanu
#@Purpose: To be run inside an alpine docker container

echo script start
if [ -z $HOME_FOLDER ]; then
	HOME_FOLDER=$HOME
	echo -e "INFO: setting \$HOME_FOLDER to $HOME";
fi
if [ -z $USER_NAME ]; then
	USER_NAME='whoami'
	echo -e "INFO: setting \$USER_NAME to 'whoami'";
fi

####install system deps####
#useing curl-dev instead of libcurl4-openssl-dev, which includes openssl-dev and curl-dev. using sqlit-dev instead of libsqlite3-dev. using yaml-dev instead of libaml-dev. using zlib-dev instead of zlib1g-dev. using py-pip instead of python-pip, this include py-setuptools so you dont need python-setuptools.
apk update
apk upgrade
#the ruby-dev package seems to be required in order to build the extensions for arachni and gauntlt however it doesnt solve all the errors
#removing bash from apk add, it was a dependency for ospd-w3af, testing if I can remove it
apk add git alpine-sdk libxml2 libxml2-dev libxslt-dev curl-dev sqlite-dev yaml-dev zlib-dev python-dev py-pip curl nmap wget tar ruby ruby-bundler gcc musl-dev ruby-dev libffi-dev make ruby-nokogiri ruby-irb
##I added bash and tar so that I can run the command after ospd-w3af
##use this line instead of w3af-console
apk -X http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --update add ospd-w3af
gem install rdoc
gem install json --no-ri
gem install gauntlt --no-ri
pip install --upgrade pip

pip install sslyze

#obtain sslyze repository so sslyze.py can be found
git clone https://github.com/iSECPartners/sslyze.git sslyze

##default usage for sslyze will be 'sslyze_cli.py targeturl.com:443'

git clone https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
#python /sqlmap-dev/sqlmap.py #error bc no flags - supress
#ln -s /sqlmap-dev/sqlmap.py /usr/bin/sqlmap

#Added ******* Added pathways for sslyze and sqlmap attacks
cat << 'EOF' >> /etc/profile

# configure attack pathways
export SSLYZE_PATH=/sslyze/sslyze.py
export SQLMAP_PATH=/sqlmap-dev/sqlmap.py
EOF

#********

##usage for sqlmap is 'python sqlmap -h' to show options.
##Below installs Go and the Heartbleed checker. The usage is simply 'Heartbleed targeturl.com:443'
if ! type "Heartbleed" > /dev/null 2>&1; then
apk add go
cat << 'EOF' >> /etc/profile

# configure go pathways
export GO_PATH=$HOME/go

EOF
	go get github.com/FiloSottile/Heartbleed
fi

#skipping dirb for now as it doesnt seem to add a lot of value but will revisit this if we need it.
#install Garmr. Usage is 'garmr -u http://targeturl.com'
#git clone https://github.com/freddyb/Garmr.git
#or this and get rid of line change line
git clone https://github.com/AndrewRot/Garmr.git

#get beautifulsoup4 from alpine edge test env
apk -X http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --update add py-beautifulsoup4

cd /Garmr
python setup.py install
cd ../

gem install io-console
#/**
#will work on getting arachni to work but saving the below code for reference
#install Arachni. Not currently working. Getting some errors with mandatory machine versions, possibly looking for something other than alpine.
#gem install arachni -v 1.0.6
#git clone -b experimental https://github.com/Arachni/arachni arachni
#cd /arachni
#gem install bundler # Use sudo if you get permission errors.
#bundle install --without prof      # To resolve possible dev dependencies.
#rake install        # To install to PATH, use sudo if you get permission errors.
#cd ../
#**/
#gem install service_manager

#Critical to open a new shell with the new environment paths binded in
source /etc/profile