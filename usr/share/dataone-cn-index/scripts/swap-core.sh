#!/bin/bash

# swaps two Solr cores
if [ "$2" = "" ]; then
  echo -n "Name of first core: "
  read name1
  echo -n "Name of second core: "
  read name2
else
  name1=$1
  name2=$2
fi

if [ ! -d /var/lib/solr/data/$name1 ] || [ $name2 = "" ]; then
  echo "Core doesn't exist"
  exit
fi

curl "http://localhost:8080/solr/admin/cores?action=SWAP&core=$name1&other=$name2"