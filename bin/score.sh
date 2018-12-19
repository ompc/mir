#!/bin/bash

gid=$1
tt_admin=$2

if [[ -z $gid ]]; then
	echo "gid is miss";
	exit;
fi

if [[ -z $tt_admin ]]; then
	echo "admin is miss";
	exit;
fi

while read line;do
	tt_player="tt"$(echo ${line}|awk '{print $1}')
	score=$(echo ${line}|awk '{print $2}')
	token=$(head -1000 /dev/urandom|md5sum|awk '{print $1}')
	curl "http://127.0.0.1:8080/guild/${gid}/player/${tt_player}/score/change/admin?admin=tt${tt_admin}&score=${score}&token=${token}"
done
