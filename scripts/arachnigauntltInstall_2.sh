#!/bin/sh
#
#@author: Joe Niquette
#@version: 0.1 8/23/16
#@Contributors: Shawn Ertel
#@Purpose: To be run inside an alpine docker container
#Usage: copy this script into a folder on your home directory, cd into the scripts folder and run ./arachnigauntltInstall_2.sh
starttime=$(date +%s.%N)
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
apk add git ruby alpine-sdk libxml2 libxml2-dev libxslt-dev curl-dev sqlite-dev yaml-dev zlib-dev python-dev py-pip curl nmap wget tar ruby ruby-bundler gcc musl-dev ruby-dev libffi-dev make ruby-nokogiri ruby-irb build-base
##I added bash and tar so that I can run the command after ospd-w3af
##use this line instead of w3af-console
pip install --upgrade pip
apk -X http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --update add ospd-w3af
gem install rdoc
gem install json --no-ri
gem install io-console --no-ri
gem install nokogiri -v 1.6.2.1 -- --use-system-libraries --no-ri
gem install json -v 1.8.1 --no-ri
#this script is to change the fbuffer file in the 1.8.1 json file. This is a dependency
#for arachni
awk '{ if (NR ==175) print " VALUE result = rb_str_new(FBUFFER_PTR(fb), FBUFFER_LEN(fb));"; else print $0}' /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h > /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h_OLD
mv /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h_OLD /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h
make -C /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/generator
gem spec /usr/lib/ruby/gems/2.2.0/cache/json-1.8.1.gem --ruby > /usr/lib/ruby/gems/2.2.0/specifications/json-1.8.1.gemspec
#install arachni
gem install arachni -v 1.0.6 --no-ri

gem install gauntlt --no-ri
gem install service_manager
echo "copying arachni attack alias file..."
cp /opt/security/alpine_gauntlt_Installscript/scripts/gauntltattackaliases/arachni.json /usr/lib/ruby/gems/2.2.0/gems/gauntlt-1.0.12/lib/gauntlt/attack_aliases/arachni.json

#Critical to open a new shell with the new environment paths binded in
source /etc/profile
endtime=$(date +%s.%N)
runtime=$(python -c "print(${endtime} - ${starttime})")
echo "Runtime was $runtime"
