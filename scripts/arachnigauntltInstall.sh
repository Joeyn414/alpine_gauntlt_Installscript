#!/bin/sh
#
#@author: Joe Niquette
#@version: 0.1 8/25/16
#@Contributors: Shawn Ertel
#@Purpose: To be run inside an alpine docker container that runs arachni and gauntlt
#Usage: copy this script into a folder on your home directory, cd into the scripts folder and run ./arachnigauntltInstall.sh

echo script start

mkdir -p /opt/security/

if [ -z $START_FOLDER ]; then
	START_FOLDER='/opt/security/'
	echo -e "INFO: setting \$START_FOLDER to '/opt/security/'";
fi

####install system deps####
#useing curl-dev instead of libcurl4-openssl-dev, which includes openssl-dev and curl-dev. using sqlit-dev instead of libsqlite3-dev. using yaml-dev instead of libaml-dev. using zlib-dev instead of zlib1g-dev. using py-pip instead of python-pip, this include py-setuptools so you dont need python-setuptools.
apk update
apk upgrade
#the ruby-dev package seems to be required in order to build the extensions for arachni and gauntlt however it doesnt solve all the errors
#removing bash from apk add, it was a dependency for ospd-w3af, testing if I can remove it
apk add ruby alpine-sdk ruby-dev make ruby-irb libffi-dev build-base 
#pip install --upgrade pip
#wget https://github.com/Arachni/arachni/releases/download/v1.4/arachni-1.4-0.5.10-linux-x86_64.tar.gz --no-check-certificate

#apk add git ruby alpine-sdk libxml2 libxml2-dev libxslt-dev curl-dev sqlite-dev yaml-dev zlib-dev python-dev py-pip curl nmap wget tar ruby ruby-bundler gcc musl-dev ruby-dev libffi-dev make ruby-nokogiri ruby-irb build-base
##I added bash and tar so that I can run the command after ospd-w3af
##use this line instead of w3af-console
#apk -X http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --update add ospd-w3af
#gem install rdoc
#gem install json --no-ri
#gem install io-console --no-ri
gem install nokogiri -v 1.6.2.1 -- --use-system-libraries --no-ri
gem install json -v 1.8.1 --no-ri
#this script is to change the fbuffer file in the 1.8.1 json file. This is a dependency for arachni
awk '{ if (NR ==175) print " VALUE result = rb_str_new(FBUFFER_PTR(fb), FBUFFER_LEN(fb));"; else print $0}' /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h > /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h_OLD
mv /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h_OLD /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h
make -C /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/generator
gem spec /usr/lib/ruby/gems/2.2.0/cache/json-1.8.1.gem --ruby > /usr/lib/ruby/gems/2.2.0/specifications/json-1.8.1.gemspec
#install arachni
gem install arachni -v 1.0.6 --no-ri

gem install gauntlt --no-ri

#obtain sslyze repository so sslyze.py can be found
#need to ensure the wget below is executed in \opt\security
#cd $START_FOLDER
#wget https://github.com/nabla-c0d3/sslyze/archive/0.13.6.tar.gz
#tar xvzf 0.13.6.tar.gz
#ln -s /opt/security/sslyze-0.13.6/sslyze_cli.py /usr/bin/sslyze
#pip install nassl
##default usage for sslyze will be 'sslyze_cli.py targeturl.com:443'

#cd $START_FOLDER
#git clone https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
#python /sqlmap-dev/sqlmap.py #error bc no flags - supress
#ln -s /opt/security/sqlmap-dev/sqlmap.py /usr/bin/sqlmap

#paths for sslyze and sqlmap
#cat << 'EOF' >> /etc/profile

# configure attack pathways
#export SSLYZE_PATH=/opt/security/sslyze-0.13.6/sslyze_cli.py
#export SQLMAP_PATH=/opt/security/sqlmap-dev/sqlmap.py
#EOF

#skipping dirb for now as it doesnt seem to add a lot of value but will revisit this if we need it.
#install Garmr. Usage is 'garmr -u http://targeturl.com'
#git clone https://github.com/freddyb/Garmr.git
#or this and get rid of line change line
#cd $START_FOLDER
#git clone https://github.com/AndrewRot/Garmr.git

#get beautifulsoup4 from alpine edge test env
#apk -X http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --update add py-beautifulsoup4

#cd Garmr/
#python setup.py install
#cd ../

#gem install service_manager

#Critical to open a new shell with the new environment paths binded in
source /etc/profile
