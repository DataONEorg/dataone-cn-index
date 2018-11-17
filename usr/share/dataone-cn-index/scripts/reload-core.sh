#!/bin/bash
# Reloads a Solr core
# 
# See https://wiki.apache.org/solr/CoreAdmin#RELOAD
#
SOLR_URL="http://localhost:8983/solr"
if [ "$1" = "" ]; then
  echo -n "Name of core to reload: "
  read name
else
  name=$1
fi

if [ ! -d /var/lib/solr/data/$name ] || [ $name = "" ]; then
  echo "Core doesn't exist"
  exit
fi

curl "${SOLR_URL}/admin/cores?action=RELOAD&core=${name}"