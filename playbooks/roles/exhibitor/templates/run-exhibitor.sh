#!/bin/bash

cd {{ exhibitor_install_dir }}

java -jar {{ exhibitor_install_dir }}/exhibitor-standalone-{{ exhibitor_version }}.jar \
  --port 8181 \
  --defaultconfig /opt/exhibitor/exhibitor.properties \
  --configtype s3 \
  --s3config {{ exhibitor_control_bucket }}:{{ aws_region }} \
  --s3backup true \
  --hostname {{ ec2_private_ip_address }}
