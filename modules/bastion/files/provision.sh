#!/usr/bin/env bash
set -xe

sudo service update_hostname restart

# ssh keys
sudo mv /ops/authorized_keys2 /home/ubuntu/.ssh/authorized_keys2
sudo chown ubuntu:users /home/ubuntu/.ssh/authorized_keys2
sudo chmod 600 /home/ubuntu/.ssh/authorized_keys2

# ssh config
sudo mv /ops/sshd_config /etc/ssh/sshd_config
sudo chmod 500 /etc/ssh/sshd_config

sudo service ssh restart
