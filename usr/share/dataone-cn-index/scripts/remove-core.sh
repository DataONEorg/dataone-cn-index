#!/bin/bash

clear
echo "*************************************************************************"
echo "*************************************************************************"
echo
echo "            You are about to *permanently* delete a core!"
echo "                      There is no going back"
echo
echo "*************************************************************************"
echo "*************************************************************************"
echo
echo -n "Type 'delete core' to continue or control-c to bail: "
read answer

if [ "$answer" != "delete core" ]; then
 exit
fi
# removes a Solr core
if [ "$1" = "" ]; then
 echo -n "Name of core to remove: "
 read name
else
 name=$1
fi

if [ ! -d /var/lib/solr/data/$name ] || [ -z "$name" ]; then
 echo "Core doesn't exist"
 exit
fi

curl "http://localhost:8080/solr/admin/cores?action=UNLOAD&core=$name"
sleep 5
rm -rf /var/lib/solr/data/$name
rm -rf  /usr/share/solr/$name
