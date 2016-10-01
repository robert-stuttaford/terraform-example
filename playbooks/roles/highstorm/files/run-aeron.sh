#!/bin/bash -ex

cd /opt

/usr/bin/java \
    -server \
    -XX:+AggressiveOpts \
    -XX:NewRatio=4 \
    -XX:SurvivorRatio=8 \
    -XX:+UseConcMarkSweepGC \
    -XX:+UseParNewGC \
    -XX:+CMSParallelRemarkEnabled \
    -XX:CMSInitiatingOccupancyFraction=60 \
    -XX:+UseCMSInitiatingOccupancyOnly \
    -XX:+CMSScavengeBeforeRemark \
    -Dfile.encoding=UTF-8 \
    -Dlogback.configurationFile=/opt/logback.xml \
    -cp /opt/app.jar cognician.highstorm.aeron_media_driver
