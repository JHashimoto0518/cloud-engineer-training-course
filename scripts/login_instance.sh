#!/bin/bash

public_ip=`aws ec2 describe-instances --instance-ids $EC2_INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text`
echo $public_ip

# TODO:sgのallowed ipを変更する

ssh -i ~/keypair/cetc2.pem ec2-user@$public_ip
