#!/bin/bash -ex

cd /opt

source /opt/cognician.env
source /opt/app.env

/usr/bin/java \
    -server \
    -Xms${COGNICIAN_XMX} -Xmx${COGNICIAN_XMX} \
    -XX:+AggressiveOpts \
    -XX:NewRatio=4 \
    -XX:SurvivorRatio=8 \
    -XX:+UseConcMarkSweepGC \
    -XX:+UseParNewGC \
    -XX:+CMSParallelRemarkEnabled \
    -XX:CMSInitiatingOccupancyFraction=60 \
    -XX:+UseCMSInitiatingOccupancyOnly \
    -XX:+CMSScavengeBeforeRemark \
    -Ddatomic.objectCacheMax=${DATOMIC_OBJECT_CACHE_MAX} \
    -Ddatomic.memoryIndexMax=${DATOMIC_MEMORY_INDEX_MAX} \
    -Ddatomic.peerConnectionTTLMsec=15000 \
    -Ddatomic.memcachedServers=$COGNICIAN_MEMCACHED_URI \
    -Dfile.encoding=UTF-8 \
    -Dlogback.configurationFile=/opt/logback.xml \
    -jar /opt/app.jar
