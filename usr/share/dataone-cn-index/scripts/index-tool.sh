#!/bin/bash

/etc/init.d/d1-index-task-generator stop
/etc/init.d/d1-index-task-generator start
/etc/init.d/d1-index-task-processor stop
java -jar /usr/share/dataone-cn-index/d1_index_build_tool.jar -a
/etc/init.d/d1-index-task-processor start
