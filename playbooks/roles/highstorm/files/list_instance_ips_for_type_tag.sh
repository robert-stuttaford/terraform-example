#!/bin/bash -ex

  aws ec2 describe-instances --output text \
    --filters "Name=tag:Type,Values=$1" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[PrivateIpAddress]'
