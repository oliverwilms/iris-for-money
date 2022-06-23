#!/bin/bash

if [ ! -d "/voldata/irisdb/irisapp" ]; then
    mkdir -p "/voldata/irisdb/irisapp"
    if [ -d "/ghostdb" ]; then
        cp -Rpfv /ghostdb/* /voldata/
    fi
fi
exit $?
