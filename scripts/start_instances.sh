#!/bin/bash

instance_id=`aws ec2 describe-instances --filters Name=tag:Name,Values="${1}" --query "Reservations[0].Instances[0].InstanceId" --output text`
echo "instance_id: ${instance_id}"
aws ec2 start-instances --instance-ids $instance_id
watch.sh aws ec2 describe-instances --instance-ids $instance_id --query "Reservations[0].Instances[0].State"