#!/bin/sh
#
#this script is to change the fbuffer file in the 1.8.1 json file. This is a dependency
#for arachni
awk '{ if (NR ==175) print " VALUE result = rb_str_new(FBUFFER_PTR(fb), FBUFFER_LEN(fb));"; else print $0}' /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h > /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h_OLD
mv /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h_OLD /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/fbuffer/fbuffer.h 
make -C /usr/lib/ruby/gems/2.2.0/gems/json-1.8.1/ext/json/ext/generator
gem spec /usr/lib/ruby/gems/2.2.0/cache/json-1.8.1.gem --ruby > usr/lib/ruby/gems/2.2.0/specifications/json-1.8.1.gemspec
