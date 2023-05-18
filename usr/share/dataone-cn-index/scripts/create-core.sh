#!/bin/bash
# creates a new Solr core
#
# See https://wiki.apache.org/solr/CoreAdmin#CREATE
# 
if [ "$1" = "" ]; then
	echo -n "Name of core to create: "
	read name
else
	name=$1
fi


TOMCAT_USER=tomcat
SOLR_URL="http://localhost:8983/solr"
mkdir /var/lib/solr/data/$name
chown ${TOMCAT_USER}:${TOMCAT_USER} /var/lib/solr/data/$name
mkdir -p /usr/share/solr/$name/conf
cp -a /usr/share/dataone-cn-index/solr-core-template/* /usr/share/solr/$name/conf/
sed -i "s/CORENAME/$name/" /usr/share/solr/$name/conf/solrconfig.xml
chown -R ${TOMCAT_USER}:${TOMCAT_USER} /usr/share/solr/$name
curl "${SOLR_URL}/admin/cores?action=CREATE&name=$name&instanceDir=/usr/share/solr/$name"
