#!/bin/bash

sudo systemctl restart chat.service
sudo systemctl restart nginx.service
sudo systemctl restart papertrail.service

exit 0
