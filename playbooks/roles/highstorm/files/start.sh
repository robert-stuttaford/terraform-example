#!/bin/bash

sudo systemctl restart aeron.service
sudo systemctl restart hs-peers.service

private_hostname=$(curl -s http://instance-data/latest/meta-data/local-ipv4)

region=$(curl -s http://instance-data/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')

leader_hostname=$(AWS_DEFAULT_REGION=$region /opt/list_instance_ips_for_type_tag.sh Highstorm | sort | uniq | awk 'NR==1{print $1}' | cut -f1 | tr -d '\n')

if [ "$private_hostname" == "$leader_hostname" ]
then
    sudo systemctl start hs-jobs.service
fi

sudo systemctl restart papertrail.service

exit 0
