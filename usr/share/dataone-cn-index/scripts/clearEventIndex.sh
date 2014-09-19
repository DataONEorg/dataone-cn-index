#!/bin/sh
#Delete all entries in the SOLR Event index
XML="<delete><query>*:*</query></delete>"
SOLR="http://localhost:8080/solr/d1-cn-log/update"

#Delete
curl "${SOLR}?commit=true" -H "Content-Type: text/xml" --data-binary ${XML}
#Optimize
curl "${SOLR}?optimize=true&waitFlush=true"