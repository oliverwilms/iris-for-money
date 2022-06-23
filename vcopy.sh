#!/bin/bash

# [INFO] Starting InterSystems IRIS instance IRIS...
# [INFO] Invalid registry ownership
# [ERROR] Command "iris start IRIS quietly" exited with status 256
##RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/local/etc/irissys/iris.reg
if [ -f "/usr/local/etc/irissys/iris.reg" ]; then
    chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/local/etc/irissys/iris.reg
fi

if [ ! -d "/voldata/irisdb/irisapp" ]; then
    mkdir -p "/voldata/irisdb/irisapp"
    if [ -d "/ghostdb" ]; then
        cp -Rpfv /ghostdb/* /voldata/
    fi
fi
exit $?
