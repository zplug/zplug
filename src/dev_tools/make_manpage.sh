#!/bin/bash

if [[ -f $ZPLUG_HOME/doc/zplug.txt ]]; then
    a2x -f manpage $ZPLUG_HOME/doc/zplug.txt
    exit $?
else
    echo "zplug.txt: not found" >&2
    exit 1
fi
