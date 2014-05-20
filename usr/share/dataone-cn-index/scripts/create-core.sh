#!/bin/bash

# creates a new Solr core
if [ "$1" = "" ]; then
	echo -n "Name of core to create: "
	read name
else
	name=$1
fi

mkdir /var/lib/solr/data/$name
chown tomcat7:tomcat7 /var/lib/solr/data/$name

mkdir -p /usr/share/solr/$name/conf

cp -a /usr/share/dataone-cn-index/solr-core-template/* /usr/share/solr/$name/conf/
sed -i "s/CORENAME/$name/" /usr/share/solr/$name/conf/solrconfig.xml
chown -R tomcat7:tomcat7 /usr/share/solr/$name
curl "http://localhost:8080/solr/admin/cores?action=CREATE&name=$name&instanceDir=/usr/share/solr/$name"
