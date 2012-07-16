#!/bin/bash

# reloads a Solr core
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

curl "http://localhost:8080/solr/admin/cores?action=RELOAD&core=$name"