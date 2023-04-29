#!/bin/zsh
cur=$(ls|grep episode|cut -b '8-')

[ ! $1 ] && ((cur++)) && mv episode* ./"episode$cur"
[ $1 ] && mv episode* ./"episode$1"
