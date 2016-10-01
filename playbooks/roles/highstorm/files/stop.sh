#!/bin/bash

sudo /bin/systemctl stop hs-jobs.service
sudo /bin/systemctl stop hs-peers.service
sudo /bin/systemctl stop aeron.service

exit 0
