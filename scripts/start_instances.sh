#!/bin/bash

aws ec2 start-instances --instance-ids $EC2_INSTANCE_ID
watch.sh aws ec2 describe-instances --instance-ids $EC2_INSTANCE_ID --query "Reservations[0].Instances[0].State"