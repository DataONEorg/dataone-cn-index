#!/bin/bash

# Migrate the solr search index to the next version.
#   configured by CONFIG_LOCATION
# 1. Stop index-processor. (Leave generator running)
# 2. Create new core.
# 3. Create link to xslt in /etc/dataone/index/solr/d1search.xsl (ABSOLUTE PATHS)
# 4. Create link to schema in /etc/dataone/index.	(ABSOLUTE PATHS)
# 5. Update solr-next.properties with new core name.
# 6. Run index-tool with -migrate option.
# 7. Swap current/live core with new, next version core.
# 8. Start index-processor. 

CONFIG_LOCATION="/etc/dataone/index/solr/schema-next.properties"
SOLR_SCRIPT_DIR="/usr/share/dataone-cn-index/scripts"
BASE_CORE_NAME="d1-cn-index"

if [ -f "$CONFIG_LOCATION" ]; then
	NEXT_CORE_NAME=`awk -F"=" '/core-name/{ print $2 }' $CONFIG_LOCATION`
	NEXT_SCHEMA_FILE=`awk -F"=" '/schema-file/{ print $2 }' $CONFIG_LOCATION`
fi

if [ -z "$NEXT_SCHEMA_FILE" ] || [ -z "$NEXT_CORE_NAME" ]; then
	echo "Must specify core-name and schema-file in $CONFIG_LOCATION"
	echo "schema-file is just file name, will be rooted from /etc/dataone/index/solr automatically."
	echo "For example: "
	echo "schema-file=solr-index-schema-v2.xml"
	echo "core-name=d1-cn-index-v2"
	exit
fi

echo "Target core name: ${NEXT_CORE_NAME} and schema: ${NEXT_SCHEMA_FILE}."
echo ""
echo "This script needs root permission to run!"
echo ""
echo "Press enter to continue with swap or ctrl-c to exit."
read key_stroke

echo "Stopping index-task-processor daemon"
/etc/init.d/d1-index-task-processor stop

echo "Creating core: ${NEXT_CORE_NAME}"
$SOLR_SCRIPT_DIR/create-core.sh $NEXT_CORE_NAME

echo "Configuring core with new schema and d1search.xsl"
ln -fs /etc/dataone/index/solr/$NEXT_SCHEMA_FILE /usr/share/solr/$NEXT_CORE_NAME/conf/schema.xml
ln -fs /etc/dataone/index/solr/d1search.xsl /usr/share/solr/$NEXT_CORE_NAME/conf/xslt/d1search.xsl

echo "Reloading core"
$SOLR_SCRIPT_DIR/reload-core.sh $NEXT_CORE_NAME

echo "Updating solr-next.properties with new core name"
cp /usr/share/dataone-cn-index/solr-template.properties /etc/dataone/index/solr-next.properties
sed -i "s/CORENAME/$NEXT_CORE_NAME/" /etc/dataone/index/solr-next.properties

echo "Building new index.  This may take a while!"
java -jar /usr/share/dataone-cn-index/d1_index_build_tool.jar -a -migrate

echo "Swapping new core into live core"
$SOLR_SCRIPT_DIR/swap-core.sh $BASE_CORE_NAME $NEXT_CORE_NAME

ln -fs /etc/dataone/index/solr/$NEXT_SCHEMA_FILE /etc/dataone/index/schema-current.xml
mv /etc/dataone/index/solr/schema.properties /etc/dataone/index/solr/schema-prev.properties
mv /etc/dataone/index/solr/schema-next.properties /etc/dataone/index/solr/schema.properties

echo "Starting index processor daemon"
/etc/init.d/d1-index-task-processor start

echo "Once the new index is verified, the old core can be removed"
echo "using: ${SOLR_SCRIPT_DIR}/remove-core.sh"
