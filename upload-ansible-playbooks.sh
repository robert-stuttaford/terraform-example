#!/bin/bash
./gen-ansible-vars.py
cd playbooks
tar cvzf ansible-playbooks.tar.gz *
cd ../
aws s3 cp playbooks/ansible-playbooks.tar.gz $(terraform output ansible_playbooks)
