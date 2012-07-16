#!/bin/bash

# Migrate the solr search index to the next version.
#
# User supplies new version number.
# 1. Stop index-processor. (Leave generator running)
# 2. Create new core.
# 3. Create link to xslt in /etc/dataone/index/solr/d1search.xsl (ABSOLUTE PATHS)
# 4. Create link to schema in /etc/dataone/index.	(ABSOLUTE PATHS)
# 5. Update solr-next.properties with new core name.
# 6. Run index-tool with -migrate option.
# 7. Swap current/live core with new, next version core.
# 8. Start index-processor. 

if [ -z "$1" ]; then
	echo -n "Target migration version number: "
	read version
else
	version=$1
fi

SOLR_SCRIPT_DIR = "."
BASE_CORE_NAME="d1-cn-index"
NEXT_CORE_NAME="d1-cn-index-v${version}"
NEXT_SCHEMA_NAME="index-solr-schema-v${version}.xml"

echo "Target core name: ${NEXT_CORE_NAME} and schema: ${NEXT_SCHEMA_NAME}"

echo "Stopping index-task-processor daemon"
/etc/init.d/d1-cn-index-/etc/init.d/d1-index-task-processor stop

echo "Creating core: ${NEXT_CORE_NAME}"
$SOLR_SCRIPT_DIR/create-core.sh $NEXT_CORE_NAME

echo "Configuring core with new schema and d1search.xsl"
ln -s /etc/dataone/index/$NEXT_SCHEMA_NAME /usr/share/solr/$NEXT_CORE_NAME/conf/schema.xml
ln -s /etc/dataone/index/solr/d1search.xsl /usr/share/solr/$NEXT_CORE_NAME/conf/xslt/d1search.xsl

echo "Updating solr-next.properties with new core name"
cp /etc/dataone/index/solr-template.properties /etc/dataone/index/solr-next.properties
sed -i "s/CORENAME/$NEXT_CORE_NAME/" /etc/dataone/index/solr-next.properties

echo "Building new index.  This may take a while!"
java -jar /usr/share/dataone-cn-index/d1_index_build_tool.jar -a -migrate

echo "Swapping new core into live core"
$SOLR_SCRIPT_DIR/swap-core.sh $BASE_CORE_NAME $NEXT_CORE_NAME

echo "Starting index processor daemon"
/etc/init.d/d1-index-task-processor start

echo "Once the new index is verified, the old core can be removed"
echo "using: ${SOLR_SCRIPT_DIR}/remove-core.sh"

