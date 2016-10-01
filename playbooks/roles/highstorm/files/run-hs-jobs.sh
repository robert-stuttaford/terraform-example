#!/bin/bash -ex

cd /opt

source /opt/cognician.env
source /opt/app.env

export COGNICIAN_ZOOKEEPER_HOSTS=$(AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION /opt/list_instance_ips_for_type_tag.sh Zookeeper | tr '\n' ',')
export COGNICIAN_HIGHSTORM_REVISION=$(cat rev.txt)

/usr/bin/java \
    -Dlogback.configurationFile=/opt/logback.xml \
    -cp /opt/app.jar cognician.highstorm.jobs
