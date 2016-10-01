#!/bin/bash

sleep 10

if ps aux | grep highstorm.jar | grep -v grep > /dev/null
then
    echo "Success"
    exit 0
else
    echo "Fail"
    exit -1
fi
