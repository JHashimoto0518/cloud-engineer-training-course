#!/bin/bash

instance_id=`aws ec2 describe-instances --filters Name=tag:Name,Values="${1}" --query "Reservations[0].Instances[0].InstanceId" --output text`
echo "instance_id: ${instance_id}"

public_ip=`aws ec2 describe-instances --instance-ids $instance_id --query "Reservations[0].Instances[0].PublicIpAddress" --output text`
echo "public_ip: ${public_ip}"

# TODO:sgのallowed ipを変更する

ssh -i ~/keypair/cetc2.pem ec2-user@${public_ip}
