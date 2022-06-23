#!/bin/bash

# [INFO] Starting InterSystems IRIS instance IRIS...
# [INFO] Invalid registry ownership
# [ERROR] Command "iris start IRIS quietly" exited with status 256
##RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/local/etc/irissys/iris.reg
if [ -f "/usr/local/etc/irissys/iris.reg" ]; then
    chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /usr/local/etc/irissys/iris.reg
fi

# [ERROR] mkdir: cannot create directory '/voldata/irisdb': Permission denied
if [ ! -f "/voldata/irisdb/irisapp/IRIS.DAT" ]; then
    mkdir -p "/voldata/irisdb/irisapp"
    if [ -d "/ghostdb" ]; then
        cp -Rpfv /ghostdb/* /voldata/
    fi
fi
exit $?
