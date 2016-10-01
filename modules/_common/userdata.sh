#!/bin/bash

sudo service codedeploy-agent stop

export ANSIBLE_PLAYBOOKS=${ansible_playbooks}
export PLAYBOOK=${playbook}

mkdir -p /tmp/ansible
cd /tmp/ansible
aws s3 cp $ANSIBLE_PLAYBOOKS /tmp/ansible/ansible-playbooks.tar.gz
tar xvzf ansible-playbooks.tar.gz
/usr/bin/ansible-playbook $PLAYBOOK.yml --connection=local -i localhost, -e target=localhost \
  --extra-vars "ec2_private_ip_address=$(curl -s http://instance-data/latest/meta-data/local-ipv4)"
