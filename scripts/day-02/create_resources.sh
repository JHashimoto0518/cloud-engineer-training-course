aws ec2 create-vpc --cidr-block 192.168.10.0/24 --tag-specifications ResourceType=vpc,Tags="[{Key=Name,Value=vpc for web}]"
echo "export WEB_VPC_ID="`aws ec2 describe-vpcs --filters Name=tag:Name,Values="vpc for web" --query 'Vpcs[].VpcId' --output text` >> ~/.bashrc
tail -n 3 ~/.bashrc
. ~/.bashrc
echo $WEB_VPC_ID
aws ec2 describe-availability-zones
aws ec2 create-subnet --vpc-id ${WEB_VPC_ID} --cidr-block 192.168.10.0/25 --availability-zone ap-northeast-1a --tag-specifications ResourceType=subnet,Tags="[{Key=Name,Value=vpc-subnet for
echo "export WEB_VPC_SUBNET_ID="`aws ec2 describe-subnets --filters Name=tag:Name,Values="vpc-subnet for web" --query "Subnets[].SubnetId" --output text` >> ~/.bashrc
tail -n 3 ~/.bashrc
. ~/.bashrc
echo $WEB_VPC_SUBNET_ID
$ aws ec2 create-internet-gateway --tag-specifications ResourceType=internet-gateway,Tags="[{Key=Name,Value=web vpc gateway}]"
$ echo "export WEB_VPC_GATEWAY_ID="`aws ec2 describe-internet-gateways --filters Name=tag:Name,Values="web vpc gateway" --query "InternetGateways[].InternetGatewayId" --output text` >> ~/.bashrc
tail -n 3 ~/.bashrc
. ~/.bashrc
echo $WEB_VPC_GATEWAY_ID
aws ec2 attach-internet-gateway --internet-gateway-id ${WEB_VPC_GATEWAY_ID} --vpc-id ${WEB_VPC_ID}
aws ec2 describe-internet-gateways --internet-gateway-id ${WEB_VPC_GATEWAY_ID} --query 'InternetGateways[]'
aws ec2 describe-route-tables --filter "Name=vpc-id,Values=${WEB_VPC_ID}" --query 'RouteTables[]'
echo "export WEB_VPC_ROUTE_TABLE_ID="`aws ec2 describe-route-tables --filter "Name=vpc-id,Values=${WEB_VPC_ID}" --query 'RouteTables[].RouteTableId' --output text` >> ~/.bashrc
tail -n 3 ~/.bashrc
. ~/.bashrc
echo $WEB_VPC_ROUTE_TABLE_ID
aws ec2 create-route --route-table-id ${WEB_VPC_ROUTE_TABLE_ID} --destination-cidr-block "0.0.0.0/0" --gateway-id ${WEB_VPC_GATEWAY_ID}
aws ec2 describe-route-tables --filter "Name=route-table-id,Values=${WEB_VPC_ROUTE_TABLE_ID}" --query "RouteTables[].Routes[]"
aws ec2 associate-route-table --subnet-id ${WEB_VPC_SUBNET_ID} --route-table-id ${WEB_VPC_ROUTE_TABLE_ID}
aws ec2 describe-route-tables --filter "Name=route-table-id,Values=${WEB_VPC_ROUTE_TABLE_ID}" --query 'RouteTables[].Associations'
