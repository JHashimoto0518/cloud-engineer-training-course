#!/bin/bash

# route table
# only custom route table

# subnet
aws ec2 delete-subnet --subnet-id ${WEB_VPC_SUBNET_ID}

# internet gateway
aws ec2 detach-internet-gateway --internet-gateway-id ${WEB_VPC_GATEWAY_ID} --vpc-id ${WEB_VPC_ID}
aws ec2 delete-internet-gateway --internet-gateway-id ${WEB_VPC_GATEWAY_ID}

# vpc
aws ec2 delete-vpc --vpc-id ${WEB_VPC_ID}