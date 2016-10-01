#!/bin/bash

sudo systemctl restart c2.service
sudo systemctl restart nginx.service
sudo systemctl restart papertrail.service

exit 0
