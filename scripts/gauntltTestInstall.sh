#!/bin/sh
echo script start
if [ -z $HOME_FOLDER ]; then
	HOME_FOLDER=$HOME
	echo -e "INFO: setting \$HOME_FOLDER to $HOME";
fi
if [ -z $USER_NAME ]; then
	USER_NAME='whoami'
	echo -e "INFO: setting \$USER_NAME to 'whoami'";
fi

##install system deps
##useing curl-dev instead of libcurl4-openssl-dev, which includes openssl-dev and curl-dev. using sqlit-dev instead of libsqlite3-dev. using yaml-dev instead of libaml-dev. using zlib-dev instead of zlib1g-dev. using py-pip instead of python-pip, this include py-setuptools so you dont need python-setuptools.
apk update
apk upgrade
apk add alpine-sdk
apk add git libxml2 libxml2-dev libxslt-dev curl-dev sqlite-dev yaml-dev zlib-dev python-dev py-pip curl nmap wget bash tar
##I added bash and tar so that I can run the command after ospd-w3af
##use this line instead of w3af-console
apk -X http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --update add ospd-w3af
apk add ruby
apk add ruby-bundler
#the ruby-dev package seems to be required in order to build the extensions for arachni and gauntlt however it doesnt solve all the errors
apk add gcc musl-dev ruby-dev libffi-dev make
gem install rdoc
gem install json --no-ri
apk add ruby-nokogiri
gem install gauntlt --no-ri
#...performing troubleshooting

#Added **** upgrade pip installer
pip install --upgrade pip
#****

pip install sslyze

#Addded *****
#obtain sslyze repository so sslyze.py can be found
git clone https://github.com/iSECPartners/sslyze.git sslyze

#set the SSLYZE_PATH in profile 
export SSLYZE_PATH=/sslyze/sslyze.py
# ****


##default usage for sslyze will be 'sslyze_cli.py targeturl.com:443'
git clone https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
python /sqlmap-dev/sqlmap.py #error bc no flags - supress
ln -s /sqlmap-dev/sqlmap.py /usr/bin/sqlmap
##usage for sqlmap is 'python sqlmap -h' to show options.
##Below installs Go and the Heartbleed checker. The usage is simply 'Heartbleed targeturl.com:443'
if ! type "Heartbleed" > /dev/null 2>&1; then
apk add go
export GOPATH=$HOME_FOLDER/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
cat << 'EOF' >> $HOME_FOLDER/.profile

# configure go pathways
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
EOF
	go get github.com/FiloSottile/Heartbleed
fi
####HEARTBLEED WORKS WITH GAUNTLT AS OF 6/21/16 0851EST####
#skipping dirb for now as it doesnt seem to add a lot of value but will revisit this if we need it.
#install Garmr. Usage is 'garmr -u http://targeturl.com'
git clone https://github.com/freddyb/Garmr.git
#seems to be hanging on the below command. If I run it from inside the /Garmr folder it seems to resolve it. But we should look into why this occuring.
cd /Garmr/
python setup.py install
cd ../
#fix the fbuffer file so that gauntlt can install correctly. The modifying of the text in this exact line isnt ideal. We may have to find something that searches for the old text at line 175 and replace it with the good text.
#cd /usr/lib/ruby/gems/2.2.0
#make -C gems/json-1.8.1/ext/json/ext/generator
#gem spec cache/json-1.8.1.gem --ruby > specifications/json-1.8.1.gemspec
#cd ~/../
#cp /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h_OLD
#awk '{ if (NR == 175) print "	 VALUE result = rb_str_new(FBUFFER_PTR(fb), FBUFFER_LEN(fb));"; else print $0}' /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h > /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h_new
#install Arachni. Not currently working. Getting some errors with mandatory machine versions, possibly looking for something other than alpine.
#gem install arachni -v 1.0.6
gem install service_manager
